class SalesOrder < ActiveRecord::Base
  attr_accessible :company_id, :quotation_id, :number, :tanggal, :top, :advance, :status, :customer_id, :retensi, :currency_id, :currency_rate, :order_ref, :salesman_id, :entries_attributes, :customer_name, :additional_charge, :additional_discount, :with_tax, :project_id
  has_many :entries, :class_name => "SalesOrderEntry"
  has_many :delivery_orders
  belongs_to :company
  belongs_to :assembly
  belongs_to :customer
  belongs_to :currency
  belongs_to :quotation
  belongs_to :salesman
  belongs_to :project
  validates_presence_of :number, :currency_id, :currency_rate
  validates_uniqueness_of :number, :scope => :company_id

  named_scope :all_closed, :conditions => { :closed => true }
  named_scope :all_open, :conditions => { :closed => false }

  accepts_nested_attributes_for :entries,
    :allow_destroy => true,
    :reject_if => lambda {|at| at['quantity'].blank? || at['quantity'].to_i == 0}

  def tgl_active
   tanggal = Chronic.parse(tanggal_berlaku)
  end

  def after_initialize
    if new_record?
      self.number = suggested_number
      self.closed = false
      self.currency = company.currencies.default.first
      self.currency_rate = self.currency.latest_rate.value
    end
  end

  def validate
    errors.add_to_base("Sales order items cannot be empty") if entries.blank?
  end

  def suggested_number
    last_number = company.sales_orders.all(:order => :number).last.try(:number)
    last_number = "#{TRANS_PREFIX[:sales_order]}.#{Time.now.strftime('%Y%m')}.00000" unless last_number
    new_number(last_number)
  end

  def build_entries_from_quot
    entries.clear
    unless quotation.blank?
      items = QuotationEntry.all(:conditions => { :quotation_id => quotation_id },
                                 :group => :item_id)
      items.each do |entry|
        self.entries.build(:item_id => entry.item_id,
                           :quantity => entry.quantity,
                           :price => entry.price,
                           :discount => entry.discount,
                           :total_price => entry.total_price)
      end
    end
  end

  def name
    number
  end

  def customer_name
    customer.try(:profile).try(:full_name)
  end

  def customer_name=(name)
    first, last = name.split(' ', 2)
    customer = Company.find(company_id).customers.first(:joins => :profile, :conditions => { 'profiles.first_name' => first, 'profiles.last_name' => last })
  end

  def undelivered_entries
    do_entries = DeliveryOrderEntry.calculate(:sum, :quantity, :conditions => { 'delivery_orders.sales_order_id' => id }, :group => :item_id, :include => :delivery_order)
    undelivered = {}; entries.collect do |entry|
      if do_entries.present? && do_entries[entry.item_id.to_i] && do_entries[entry.item_id.to_i] < entry.quantity
        undelivered[entry.item_id.to_i] = entry.quantity - do_entries[entry.item_id.to_i]
      end
    end
    undelivered
  end

  def all_entries_delivered?
    undelivered_entries.blank?
  end

  def total_value
    entries.map(&:total_price).sum
  end
  
  def grand_total
    (total_value + additional_charge) - additional_discount
  end

  def tax_value
    with_tax? ? (grand_total * 10 / 100) : 0
  end

  def grand_total_plus_tax
    grand_total + tax_value
  end

  def plu_complete?
    entries.detect { |e| e.plu_id.nil? }.blank?
  end

  def update_delivered
    entries.each { |e| e.update_delivered }
    project.update_delivered_materials unless project.nil?
  end

end

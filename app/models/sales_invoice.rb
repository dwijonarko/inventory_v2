class SalesInvoice < ActiveRecord::Base
  attr_accessible :company_id, :delivery_order_ids, :number, :ppn, :due_time, :top, :sales_commission, :user_date, :discount
  has_many :delivery_orders
  belongs_to :sales_order
  belongs_to :company
  validates_presence_of :number
  validates_uniqueness_of :number, :scope => :company_id

  def nama
    number
  end

  def after_initialize
    self.number = suggested_number if new_record?
  end

  def suggested_number
    last_number = company.sales_invoices.all(:order => :created_at).last.try(:number)
    last_number = "#{TRANS_PREFIX[:sales_invoices]}.#{Time.now.strftime('%Y%m')}.00000" unless last_number
    new_number(last_number)
  end

  def tgl_active
   date = Chronic.parse(due_date)
  end

  def grand_total
    delivery_orders.map(&:grand_total).sum - discount
  end

  #def build_entries_from_do
    #entries.clear
    #unless delivery_order_id.blank?

      #data_do = DeliveryOrder.all(:conditions => {:sales_order_id => sales_order_id}).collect{|d| d.id}
      #item_do = DeliveryOrderEntry.calculate(:sum,
                                           #:quantity,
                                           #:conditions => {:delivery_order_id => data_do},
                                           #:group => :item_id)


      #sales_order.entries.each do |so_data|
        #item_dos = item_do.detect{|do_data1, do_data2| do_data1 == so_data.item_id.to_i}
        #self.entries.build(:item_id => so_data.item_id,
                           #:quantity => so_data.quantity - item_dos[1].to_i)

      #end
    #end
  #end

end


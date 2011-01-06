class TransDiassembly < ActiveRecord::Base
  attr_accessible :company_id, :warehouse_id, :trans_assembly_id, :number, :quantity, :description, :tanggal, :entries_attributes
  belongs_to :company
  belongs_to :warehouse
  belongs_to :trans_assembly
  has_many :entries, :class_name => "TransDiassembliesEntry"
  validates_presence_of :number, :quantity, :warehouse_id, :trans_assembly_id, :tanggal
  validates_uniqueness_of :number, :scope => :company_id
  
  accepts_nested_attributes_for :entries,
    :allow_destroy => true,
    :reject_if => lambda {|at| at['quantity'].blank? || at['quantity'].to_i == 0}

  def after_initialize
    self.number = suggested_number if new_record?
  end

  def suggested_number
    last_number = company.trans_diassemblies.all(:order => :created_at).last.try(:number)
    last_number = "#{TRANS_PREFIX[:trans_diassemblies]}.#{Time.now.strftime('%Y%m')}.00000" unless last_number
    new_number(last_number)
  end

  def tgl_active
   tanggal = Chronic.parse(tanggal)
  end

  def build_entries_from_trad
    entries.clear
    unless trans_assembly.blank?
      items = TransAssembliesEntry.calculate(:sum,
                                             :quantity,
                                             :conditions => { :trans_assembly_id => trans_assembly_id },
                                             :group => :item_id)
      items.each do |item_id, qty|
        self.entries.build(:item_id => item_id,
                           :quantity => qty)
      end
    end
  end

  def to_s
    number
  end

end

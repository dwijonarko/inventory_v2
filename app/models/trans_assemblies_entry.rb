class TransAssembliesEntry < ActiveRecord::Base
  belongs_to :trans_assembly
  belongs_to :assembly
  has_many :progress_entries, :class_name => "AssemblyProgressEntry", :foreign_key => "assembly_entry_id"

  def assembly_name
    assembly.try(:name)
  end
  
  def assembly_name=(name)
  end

  def item_name
    assembly.try(:item).try(:name)
  end

  def completed
    progress_entries.sum(:quantity)
  end

end

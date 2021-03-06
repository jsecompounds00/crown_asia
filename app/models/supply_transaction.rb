class SupplyTransaction < ActiveRecord::Base

  belongs_to :supply
  belongs_to :issued_department, :class_name => "Department"
  belongs_to :issued_user, :class_name => "User"
  belongs_to :issued_customer, :class_name => "Customer"
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  belongs_to :supplier
  
  has_many :supply_transaction_items, :dependent => :destroy
  
  accepts_nested_attributes_for :supply_transaction_items, :allow_destroy => true, :reject_if => lambda { |a| a[:supply_id].blank? && a[:quantity].blank? && a[:unit_price].blank? }
  
  validates :transaction_date, :supply_type, :presence => true
  
  validates :rr_number, :pre_number, :supplier, :presence => true, :if => Proc.new { |transaction| transaction.transaction_type == "add" }
  validates :rr_number, :pre_number, :format => {:with => /[0-9]+/}, :if => Proc.new { |transaction| transaction.transaction_type == "add" }
  validates :po_number, :format => {:with => /[0-9]+/}, :allow_blank => true, :allow_nil => true, :if => Proc.new { |transaction| transaction.transaction_type == "add" }
  
  validates :mirs_number, :issued_department, :presence => true, :if => Proc.new { |transaction| transaction.transaction_type == "sub" }
  validates :mirs_number, :format => {:with => /[0-9]+/}, :if => Proc.new { |transaction| transaction.transaction_type == "sub" }
  validates :misc_sales_number, :sr_number, :format => {:with => /[0-9]+/}, :allow_nil => true, :allow_blank => true, :if => Proc.new { |transaction| transaction.transaction_type == "sub" }
  
  validates :issued_user, :presence => true, :if => Proc.new { |transaction| transaction.transaction_type == "sub" && transaction.supply_type != "Scrap" }
  validates :issued_customer, :presence => true, :if => Proc.new { |transaction| transaction.transaction_type == "sub" && transaction.supply_type == "Scrap" }
  
  validate :supply_quantity
  
  acts_as_paranoid
  
  acts_as_audited :except => [:deleted_at]
  
  def supply_quantity
    return if self.transaction_type != "sub"
    self.supply_transaction_items.each do |item|
      if item.quantity && item.quantity > item.supply.quantity_on_hand
        errors.add(:base, "Transaction item quantity cannot be more than the remaining quantity of the supply")
        return
      end
    end
  end
  
  def supplier_name
    return "" if self.supplier.nil?
    return self.supplier.name
  end
  
end
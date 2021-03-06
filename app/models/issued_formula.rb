class IssuedFormula < ActiveRecord::Base
  belongs_to :finished_good
  belongs_to :formula
  belongs_to :mixer
  belongs_to :extruder
  
  has_many :issued_formula_items
  has_many :issued_formula_batches
  
  validates :resin_big_batch_quantity, :resin_small_batch_quantity, :numericality => true
  validates :big_batch_quantity, :small_batch_quantity, :numericality => true
  validates :issuance_date, :presence => true
  # validates :lot_number, :uniqueness => true, :allow_nil => true, :allow_blank => true
  
  validate :resin_quantity
  
  before_create :set_control_number
  
  after_create :create_items
  
  def cancel_big_batch!
    self.update_attribute(:canceled_big_batch, true)
  end
  
  def cancel_small_batch!
    self.update_attribute(:canceled_small_batch, true)
  end
  
  def canceled?
    self.canceled_big_batch && self.canceled_small_batch
  end
  
  def issued?
    !self.production_date.blank? && !self.lot_number.blank?
  end
  
  def next_control_number
    year = self.issuance_date.strftime("%y")
    last_issued = IssuedFormula.last(:conditions => ["issuance_date >= ? AND issuance_date < ?", Date.parse("1/1/#{self.issuance_date.year}"), Date.parse("1/1/#{self.issuance_date.year + 1}")])
    number = last_issued && last_issued.control_number ? last_issued.control_number.split("-")[1].to_i + 1 : 1
    number = "%04d" % number
    "#{year}-#{number}"
  end
  
  def big_batch_total
    self.resin_big_batch_quantity * self.big_batch_quantity
  end
  
  def small_batch_total
    self.resin_small_batch_quantity * self.small_batch_quantity
  end
  
  protected
    def resin_quantity
      errors.add(:base, "Resin quantities must be divisible by 25.") if self.resin_big_batch_quantity % 25 != 0 || self.resin_small_batch_quantity % 25 != 0
    end
    
    def create_items
      resin = self.formula.resin_formula_item
      formula_items = self.formula.formula_items - [resin]
      
      # Create resin item
      IssuedFormulaItem.create(:issued_formula => self,
                               :raw_material => resin.raw_material,
                               :big_batch_quantity => self.resin_big_batch_quantity * self.big_batch_quantity,
                               :small_batch_quantity => self.resin_small_batch_quantity * self.small_batch_quantity)
                               
      # Create other items
      formula_items.each do |item|
        IssuedFormulaItem.create(:issued_formula => self,
                                 :raw_material => item.raw_material,
                                 :big_batch_quantity => self.resin_big_batch_quantity * self.big_batch_quantity * item.multiplier,
                                 :small_batch_quantity => self.resin_small_batch_quantity * self.small_batch_quantity * item.multiplier)
      end
    end
    
    def set_control_number
      self.control_number = self.next_control_number
    end
end

module DeliverySchedulesHelper
  def time_options
    options = [["", ""]]
    0.upto(23){|i| options << ["#{i}:00", "#{i}:00"]}
    options
  end
  
  def item_options(item_type)
    if item_type.blank?
      [["", ""]]
    else
      [["", ""]] + Object.const_get(item_type).where("active = 1").order("name").collect{|f| [f.name, f.id]}
    end
  end
end

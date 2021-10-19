class KnapSack
  attr_reader :weight, :value
  attr_writer :weight, :value
  
  def initialize(weight, value)
    @weight = weight
    @value = value 
  end
  
  def to_s
    "{weight:#{weight}, value:#{value}}"
  end
end

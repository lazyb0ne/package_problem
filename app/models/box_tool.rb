class BoxTool
  attr_writer :bags, :total_weight
  attr_reader :bags, :total_weight, :best_value, :best_values, :best_solutions
  
  def initialize(bags, total_weight)
    @bags = bags
    @total_weight = total_weight
    @n = bags.length
    @best_values = Array.new(@n + 1) { Array.new(@total_weight + 1) } 
    @best_solutions = Array.new
  end
  
  def solve
    t1 = Time.now
    # puts '给定背包:'
    # bags.each do |bag|
    #   puts bag.to_s
    # end
    
    # puts '给定总称重: ' + @total_weight.to_s
    
    (0..@total_weight).each do |j| 
      (0..@n).each do |i| 
        if i == 0 || j == 0
          @best_values[i][j] = 0
        else
          if j < @bags[i - 1].weight
            @best_values[i][j] = @best_values[i - 1][j]
          else
            iweight = @bags[i - 1].weight
            ivalue = @bags[i - 1].value
            @best_values[i][j] = [@best_values[i - 1][j], ivalue + @best_values[i - 1][j - iweight]].max
          end
        end
      end
    end  
    
    temp_weight = @total_weight
    @n.downto(1).each do |i|
      if @best_values[i][temp_weight] > @best_values[i - 1][temp_weight]
        @best_solutions.push(@bags[i - 1])
        temp_weight -= @bags[i - 1].weight
        if temp_weight == 0
          break
        end
      end
      @best_value = @best_values[@n][@total_weight]
    end  
    t2 = Time.now
    # puts "solve cost:#{(t2-t1).round(2)} "
  end
end

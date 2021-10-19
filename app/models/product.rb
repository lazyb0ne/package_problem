class Product
	attr_accessor :name, :price, :in_use, :weight, :value

	def initialize
        @price = 0
        @name = ""
        @in_use = 0
        @weight = 0
        @value = 0
        @selected = 0
    end

    def show
        puts "#{@name} #{@price.to_f.round(2)} in_use:#{@in_use}"
    end

    
end
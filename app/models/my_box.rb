class MyBox
	
	attr_accessor :amount, :name, :list, :amount_all, :is_full, :diff

    def initialize
        @list = []
        @amount_all = 0
        @name = ""
        @amount = 0
        @is_full = 0
    end

    def check_add p
        if @is_full == 1 || @amount < p.price + @amount_all
            return false
        end
        @list << p
        @amount_all = @amount_all.to_f + p.price.to_f
        @is_full =  @amount.to_f == @amount_all.to_f ? 1 : 0
        @diff = (@amount - @amount_all).round(2)
        p.in_use = 1
        return true
    end

    def do_add p
        if p.in_use == 1 || @is_full == 1 || @amount < p.price + @amount_all
            return 
        end
        @list << p
        @amount_all = @amount_all.to_f + p.price.to_f
        @is_full =  @amount.to_f.round(2) == @amount_all.to_f.round(2) ? 1 : 0
        @diff = (@amount - @amount_all).round(2)
        p.in_use = 1
    end

    def check_full?
    	return @amount == @amount_all ? 1 : 0 
    end

    def show
    	puts "#{@name} #{@amount.to_f.round(2)} full? #{check_full?} list size=#{@list.size} amount_all:#{@amount_all.round(2)} diff=#{@diff}"
    end




end
require 'simple_xlsx_reader'

class Lazy

	attr_accessor :product_list, :box_list

	def initialize
	    @product_list = []
		@box_list = []
		init
	end

	def init
		# 初始化商品数据
		doc = SimpleXlsxReader.open("/Users/lazybone/workspace/ruby/data.xlsx")
		sheet = doc.sheets.first
		sheet.rows.each_with_index do |row,index|
		    next if index == 0 || row.size != 4
		    row[1].to_i.times do
		        p = Product.new 
		        p.name = row[0]
		        p.price = row[2].to_f
		        p.value = row[2].to_f
		        p.weight = row[2].to_f
		        @product_list << p  
		    end
		end

		# 初始化背包数据
		sheet = doc.sheets[1]
		sheet.rows.each_with_index do |row,index|
		    next if index == 0 
		    p = MyBox.new 
		    p.name = row[0]
		    p.amount = row[1].to_f
		    next if row[0].blank?
		    @box_list << p  
		end

		# 背包排序
		sort_list

		puts "Init OK"
		puts "@product_list size:" + @product_list.size.to_s
		puts "@box_list size:" + @box_list.size.to_s
	end

	def solve_test
		bags = product_list_not_use
	    total_weight = 587
	    kp = BoxTool.new(bags, total_weight)
	    kp.solve
	    puts " -------- 该背包问题实例的解: --------- "
	    puts "最优值：#{kp.best_value}"
	    puts "最优解【选取的背包】: "
	    print kp.best_solutions, "\n"
	    return 
	    puts "最优值矩阵："
	    best_values = kp.best_values
	    best_values.each  do |r|
	      r.each do |c|
	        printf("%-5d", c) 
	      end
	      puts
	    end
	end

	def solve_1
		bags = [KnapSack.new(2, 2), KnapSack.new(10, 10), KnapSack.new(3, 3), KnapSack.new(2, 2), 
            KnapSack.new(4, 4), KnapSack.new(5, 5), KnapSack.new(20, 20), KnapSack.new(8, 8)]
	    total_weight = 20
	    kp = BoxTool.new(bags, total_weight)
	    kp.solve
	    puts " -------- 该背包问题实例的解: --------- "
	    puts "最优值：#{kp.best_value}"
	    puts "最优解【选取的背包】: "
	    print kp.best_solutions, "\n"
	    return 
	    puts "最优值矩阵："
	    best_values = kp.best_values
	    best_values.each  do |r|
	      r.each do |c|
	        printf("%-5d", c) 
	      end
	      puts
	    end
	end


	def sort_list
		@box_list.sort!{ |a,b| a.amount.to_f <=> b.amount.to_f}
		@box_list.reverse!

		@product_list.sort!{ |a,b| a.price.to_f <=> b.price.to_f}
		@product_list.reverse!
	end

	def show kind=0
		if kind == 1
			@box_list.each do |a|
				a.show
			end
		end
		puts "===== show box ======"
		puts "box:#{@box_list.size} full:#{box_list_full.count} not full:#{box_list_not_full.count} "
		puts "box diff: #{box_list_not_full.map(&:diff).sort.uniq}" rescue nil
		
		puts "===== show @product_list ======"
		puts "product_list not in_use:  #{product_list_not_use.size}"
		
		# @product_list.each do |a|
		# 	a.show
		# end
		puts "product_list price: #{product_list_not_use.map(&:price).sort}" rescue nil
		puts ""
	end

	# 机械的添加
	def deal
		product_list_not_use.each do |a|
			box_list_not_full.each do |b|
				result = b.check_add a
				break if result
			end
		end
	end

	# 开始进行随机处理
	def deal_one n=nil
		t1 = Time.now
		if n > 0
			n.times{
				box_random.check_add product_random
			}
		else
			100.times{
				box_random.check_add product_random
			}
		end
		show
		t2 = Time.now
		puts "n:#{n} cost:#{t2-t1}"
	end

	# 是否已经结束
	def check_is_ok?
		puts "box notfull: #{box_list_not_full.size}"
		box_list_not_full.blank?
	end


	# =================== 方法
	def box_list_full
        @box_list.select{|a|a.is_full == 1 }
    end

    def box_list_not_full
        @box_list.select{|a|a.is_full == 0 }
    end

    def product_list_use
    	@product_list.select{|a|a.in_use == 1}
    end

    def product_list_not_use
    	@product_list.select{|a|a.in_use == 0}
    end

    def product_random
    	list = product_list_not_use
    	list[rand(list.size)]
    end

    def box_random
    	list = box_list_not_full
    	list[rand(list.size)]
    end

    def get_product_by total
    end

end
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

	def solve_test show_info=false

		success = 0 
		faild = 0 
		all = box_list_not_full.size
		t1 = Time.now
		success_info = ''
		idx = 0
		count_hash = {}
		box_list_not_full.each do |a|
			count_hash[a.name] = 0
		end
		is_success = 0

		while box_list_not_full.size >0
			box = box_random

			count_hash[box.name] = count_hash[box.name] + 1
			t3 = Time.now
			total_weight = box.amount
			info = get_select_product_by total_weight
			bags = product_list_not_use.select{|a|a.selected == 1}
		    kp = BoxTool.new(bags, total_weight)
		    kp.solve
		    t4 = Time.now
		    idx = idx + 1

		    is_success = (box.amount.to_f.round(2) == kp.best_value.to_f.round(2)) ? 1:0
			
			if is_success == 1
				bags.each{|a| a.selected = 0}
				success += 1
				success_info = "OK"
			else
				bags.each{|a| a.selected = 1}
				# return 
				faild += 1
				success_info = "X"
			end

			puts "%-3s 背包:%-6s try:%-3s cost:%-6s cost all:%-6s 目标值:%-8s 最优值:%-8s ALL:%-5s success:%-5s faild:%-5s info:%-10s %-3s" % 
				[
					idx,
					box.name,
					count_hash[box.name],
					(t4-t3).to_f.round(2),
					(Time.now-t1).to_f.round(2),
					box.amount.round(2),
					kp.best_value.round(2),
					all,
					success,
					faild,
					info,
					success_info
				]


		    puts "最优解【选取的背包】: " if show_info
		    print kp.best_solutions, "\n" if show_info
	        
		    best_values = kp.best_values
		    if show_info
		    	puts "最优值矩阵："
			    best_values.each  do |r|
			      r.each do |c|
			        printf("%-5d", c) 
			      end
			      puts
			    end
			end
		    # 重置数据
		    if is_success
				kp.best_solutions.each{|a| a.in_use = 1 }
			    bags.each{|a| a.selected = 1}
			    kp.best_solutions.each{|a| box.do_add a }
			    box.is_full = 1
			end
		end
	end

	def solve_demo
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
		# @box_list.reverse!

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
    	list = box_list_not_full.first(10)
    	# list = @box_list.first(3)
    	list[rand(list.size)]
    end

    def get_select_product_by total
    	step = 10
    	sum = product_list_not_use.select{|a|a.selected == 1}.map(&:price).sum rescue 0
    	while sum < total 
	    	product_list_to_calc = []
	    	# 分组
	    	# [["22713025", 1500], ["20182038", 7550], ["20104252", 1], 
	    	name_list = product_list_not_use.map(&:name).uniq
	    	name_list.each do |name|
	    		product_list_not_use.select{|a|a.name == name}.each_with_index do |b,index|
	    			b.selected = 1
	    			break if index >= step
	    		end
	    	end
	    	step += 10
	    	sum = product_list_not_use.select{|a|a.selected == 1}.map(&:price).sum rescue 0
	    end
	    select_list = product_list_not_use.select{|a|a.selected == 1}
	    return "total:%-8s step:%-4s sum:%-8s selected count:%-6s" %
	    		[
	    			total.round(2),step.round(2),sum.round(2),select_list.size
	    		]
    end

end
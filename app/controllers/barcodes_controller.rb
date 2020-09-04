class BarcodesController < ApplicationController

	def new
		
	end 

	def generate
		count = rand(1..100)
		start_count = count
		barcode_num = '1'
		while count > 0
			bar = Barcode.new(source: :generator)
			bar.barcode, barcode_num = bar.find_unique_barcode(barcode_num)
			bar.save!
			count -= 1
		end

		flash[:notice] = "#{start_count} barcodes imported!"
    	redirect_to action: 'index'
	end

	def import
		@barcode = Barcode.new
		@success_count = 0
		@errors = []
		@message = 'Invalid barcodes found:'
		@barcode.save_excel_file(params[:file])
		worksheet = RubyXL::Parser.parse("#{Rails.root.join('public', 'uploads', params[:file].original_filename)}")[0]
		ActiveRecord::Base.transaction do
			@results = worksheet.drop(1).each do |row|
				begin
					bar = Barcode.new(source: :excel)
					bar.clean_barcode(row[0].value)
					bar.save!
				rescue ActiveRecord::RecordInvalid => e
					@errors << e
					@message += " #{row[0].value},"
					next
				else
					@success_count += 1
				end
			end
			if @errors.present?
				raise ActiveRecord::Rollback
			end
		end

		if @errors.present?
			flash[:alert] = "#{@message}"
    		render 'new'
  		else
  			flash[:notice] = "#{@success_count} barcodes imported!"
    		redirect_to action: 'index'
  		end
	end
end

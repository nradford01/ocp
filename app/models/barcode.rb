class Barcode < ActiveRecord::Base
	enum source: [:excel, :generator]

	validates_uniqueness_of :barcode

	validate :is_ean8 


	def clean_barcode(code)
		return self.barcode = code if EAN8.valid?(code)
		return unless code.is_a? String
		if code.length < 8
			if EAN8.new(code.rjust(8, "0")).valid?
				return self.barcode = code.rjust(8, "0")
			else 
				return self.barcode = EAN8.complete(code.rjust(7, "0"))
			end
		end
	end

	def find_unique_barcode(barcode_num)
		ean8 = EAN8.complete(barcode_num.rjust(7, "0"))
		if Barcode.find_by_barcode(ean8)
			new_num = barcode_num.to_i 
			new_num += 1
			find_unique_barcode(new_num.to_s)
		else 
			return ean8, barcode_num
		end
	end

	def save_excel_file(file)
		uploaded_file = file
  		File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    		file.write(uploaded_file.read)
   		end
   	end
	

	private

	def is_ean8
		puts self.barcode
		unless EAN8.new(self.barcode).valid?
			errors.add(:barcode, 'barcode is not a valid EAN8')
		end
	end

end
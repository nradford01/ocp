class ChangeBarcodeToString < ActiveRecord::Migration[5.2]
  def change
  	change_column :barcodes, :barcode, :string
  end
end

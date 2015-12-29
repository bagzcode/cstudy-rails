class CreateMovements < ActiveRecord::Migration
  def change
    create_table :movements do |t|
      t.string :code
      t.string :source_code
      t.string :source_sub_district_name
      t.string :source_district_name
      t.string :destination_code
      t.string :destination_sub_district_name
      t.string :destination_district_name
      t.integer :weekly_volume
      t.integer :number_of_connectivity
      t.integer :category

      t.timestamps null: false
    end
  end
end

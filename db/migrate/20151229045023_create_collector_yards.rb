class CreateCollectorYards < ActiveRecord::Migration
  def change
    create_table :collector_yards do |t|
      t.string :code
      t.string :code_old
      t.string :name
      t.string :owner_name
      t.string :address
      t.string :sub_district_name
      t.string :district_name
      t.float :longitude
      t.float :latitude
      t.boolean :is_cluster
      t.string :cluster_name
      t.integer :category

      t.timestamps null: false
    end
  end
end

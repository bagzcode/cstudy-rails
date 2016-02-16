class CreateMovementIns < ActiveRecord::Migration
  def change
    create_table :movement_ins do |t|
      t.integer :movement_id
      t.string :origin_district
      t.integer :collector_type_id
      t.integer :species_type_id
      t.integer :number
      t.integer :weekly_volume
      t.string :destination_code
      t.string :destination_name
      t.float :destination_x
      t.float :destination_y
      t.string :destination_district
      t.string :destination_subdistrict
      t.float :point_x_subdistrict_destination
      t.float :point_y_subdistrict_destination
      t.string :object_id_subdistrict_destination
      t.float :in_km_distance_origin_district_destination
      t.string :destination_in_cluster
      t.string :destination_cluster_name
      t.string :cy_id

      t.timestamps null: false
    end
  end
end

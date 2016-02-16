class CreateMovementOuts < ActiveRecord::Migration
  def change
    create_table :movement_outs do |t|
      t.string :movement_id
      t.string :origin_code
      t.string :origin_name
      t.string :origin_district
      t.string :origin_sub_district
      t.string :origin_x
      t.string :origin_y
      t.integer :species_type_id
      t.integer :number
      t.integer :weekly_volume
      t.integer :collector_type_id
      t.string :name_destination
      t.string :destination_lbm_cy_id
      t.string :destination_district
      t.string :destination_sub_district
      t.float :destination_x_original
      t.float :destination_y_original
      t.string :xy
      t.float :point_x_subdistrict
      t.float :point_y_subdistrict
      t.string :object_id_destination
      t.float :in_km_distance_origin_destination
      t.string :origin_in_cluster
      t.string :cluster_name

      t.timestamps null: false
    end
  end
end

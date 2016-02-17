require 'csv'
namespace :cs do
  task :import_movement_out => :environment do
    i = 0
    added_row = 0
    updated_row = 0
    filename = "movement_out_new"
    puts ">> Loading data in #{filename}.csv"
    CSV.foreach(Rails.root.join("db", "#{filename}.csv"), :headers => true) do |row|
      m = MovementOut.where(:movement_id => row["movement_id"]).first_or_initialize

      puts "Movement Out >> #{i=i+1}, #{row["movement_id"]} #{ m.new_record? ? 'NEW' : 'UPDATE' }"

      if m.new_record?
        added_row += 1
      else
        updated_row += 1
      end

      m.movement_id = row["movement_id"]
      m.origin_code = row["origin_code"]
      m.origin_name = row["origin_name"]
      m.origin_district = row["origin_district"]
      m.origin_sub_district = row["origin_sub_district"]
      m.origin_x = row["origin_x"]
      m.origin_y = row["origin_y"]
      m.number = row["number"]
      m.weekly_volume = row["weekly_volume"]
      m.name_destination = row["name_destination"]
      m.destination_lbm_cy_id = row["destination_lbm_cy_id"]
      m.destination_district = row["destination_district"]
      m.destination_sub_district = row["destination_sub_district"]
      m.destination_x_original = row["destination_x_original"]
      m.destination_y_original = row["destination_y_original"]
      m.xy = row["xy"]
      m.point_x_subdistrict = row["point_x_subdistrict"]
      m.point_y_subdistrict = row["point_y_subdistrict"]
      m.object_id_destination = row["object_id_destination"]
      m.in_km_distance_origin_destination = row["in_km_distance_origin_destination"]
      m.origin_in_cluster = row["origin_in_cluster"]
      m.cluster_name = row["cluster_name"]

      # Check on Collector Type
      collector_type = CollectorType.where(code: row["type_destination"]).first_or_initialize
      collector_type.save if collector_type.new_record?
      m.collector_type_id = collector_type.id

      # Check on SpeciesType
      species_type = SpeciesType.where(code: row["species"]).first_or_initialize
      species_type.save if species_type.new_record?
      m.species_type_id = species_type.id

      m.save!
    end

    puts "Import is finished with #{added_row} added row(s) and #{updated_row} updated row(s)"
  end
end
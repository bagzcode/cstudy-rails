require 'csv'
namespace :cs do
  task :import_movement_in => :environment do
    i = 0
    added_row = 0
    updated_row = 0
    filename = "movement_in_new"
    puts ">> Loading data in #{filename}.csv"
    CSV.foreach(Rails.root.join("db", "#{filename}.csv"), :headers => true) do |row|
      m = MovementIn.where(:movement_id => row["movement_id"]).first_or_initialize

      puts "Movement In << #{i=i+1}, #{row["movement_id"]} #{ m.new_record? ? 'NEW' : 'UPDATE' }"

      if m.new_record?
        added_row += 1
      else
        updated_row += 1
      end

      m.movement_id = row["movement_id"]
      m.origin_district = row["origin_district"]
      m.number = row["number"]
      m.weekly_volume = row["weekly_volume"]
      m.destination_code = row["destination_code"]
      m.destination_name = row["destination_name"]
      m.destination_x = row["destination_x"]
      m.destination_y = row["destination_y"]
      m.destination_district = row["destination_district"]
      m.destination_subdistrict = row["destination_subdistrict"]
      m.point_x_subdistrict_destination = row["point_x_subdistrict_destination"]
      m.point_y_subdistrict_destination = row["point_y_subdistrict_destination"]
      m.object_id_subdistrict_destination = row["object_id_subdistrict_destination"]
      m.in_km_distance_origin_district_destination = row["in_km_distance_origin_district_destination"]
      m.destination_in_cluster = row["destination_in_cluster"]
      m.destination_cluster_name = row["destination_cluster_name"]
      m.cy_id = row["cy_id"]

      # Check on Collector Type
      collector_type = CollectorType.where(code: row["type"]).first_or_initialize
      collector_type.save if collector_type.new_record?
      m.collector_type_id = collector_type.id

      # Check on SpeciesType
      species_type = SpeciesType.where(code: row["species"]).first_or_initialize
      species_type.save if species_type.new_record?
      m.species_type_id = species_type.id

      m.save
    end

    puts "Import is finished with #{added_row} added row(s) and #{updated_row} updated row(s)"
  end
end
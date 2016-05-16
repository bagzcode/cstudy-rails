require 'csv'

# Fields
#
# in movement_in.csv:
# ===================
# - movement_id
# - origin_district
# - destination_code
# - destination_name
# - destination_district
# - destination_sub_district
# - destination_X
# - destination_Y
# - destination_in_cluster
# - destination_cluster_name
# - species
# - number
# - weekly_volume

# in movement_out.csv:
# ====================
# - movement_id
# - origin_code
# - origin_name
# - origin_district
# - origin_sub_district
# - origin_X
# - origin_Y
# - origin_in_cluster
# - cluster_name
# - destination_LBM_CY_id
# - destination_district
# - destination_sub_district
# - destination_X
# - destination_Y
# - species
# - number
# - weekly_volume

# in database:
# ============
# - code
# - source_code
# - source_sub_district_name
# - source_district_name
# - destination_code
# - destination_sub_district_name
# - destination_district_name
# - weekly_volume
# - number_of_connectivity
# - category
# - species_type_id

namespace :cs do
  task :load_movement => :environment do
    i = 0
    %w(movement_in movement_out).each do |file_name|
      puts ">> Loading data in #{file_name}.csv"
      CSV.foreach(Rails.root.join("db", "#{file_name}.csv"), :headers => true) do |row|
        puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{i=i+1}, #{row["movement_id"]}"

        m = Movement.where(:code => row["movement_id"]).first_or_initialize
        m.source_district_name = row["origin_district"]

        if file_name == "movement_out"
          m.source_code = row["origin_code"]
          m.source_sub_district_name = row["origin_sub_district"]
          m.destination_code = row["destination_LBM_CY_id"]
          m.category = "out"

          # Check on Clusters
          if row["origin_in_cluster"] and row["origin_in_cluster"].downcase == "yes" and row["origin_code"].present? and row["cluster_name"].present?
            puts "--> updating cluster on cy"
            cy = CollectorYard.where(code: row["origin_code"])
            if cy.count > 0
              cy.first.is_cluster = true
              cy.first.cluster_name = row["cluster_name"]
              cy.first.save
            end
          end
        else
          m.destination_code = row["destination_code"]
          m.category = "in"

          # Check on Clusters
          if row["destination_in_cluster"].present? and row["destination_in_cluster"].downcase == "yes" and row["destination_code"].present? and row["destination_cluster_name"].present?
            puts "--> updating cluster on cy"
            cy = CollectorYard.where(code: row["destination_code"])
            if cy.count > 0
              cy.first.is_cluster = true
              cy.first.cluster_name = row["destination_cluster_name"]
              cy.first.save
            end
          end
        end

        m.destination_sub_district_name = row["destination_sub_district"]
        m.destination_district_name = row["destination_district"]
        m.weekly_volume = row["weekly_volume"]
        m.number_of_connectivity = row["number"]

        # Check on SpeciesType
        species_type = SpeciesType.where(code: row["species"]).first_or_initialize
        if species_type.new_record?
          species_type.save
        end
        m.species_type_id = species_type.id

        m.save!
      end
    end
  end
end
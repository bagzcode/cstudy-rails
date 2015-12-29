require 'csv'

# Fields
#
# in csv:
# =======
# - code
# - name
# - district
# - sub_district
# - X --> longitude
# - Y --> latitude
# - type

# in database:
# ============
# - code
# - code_old
# - name
# - owner_name
# - address
# - sub_district_name
# - district_name
# - longitude
# - latitude
# - is_cluster
# - cluster_name
# - category

namespace :cs do
  desc "Loading collector yards"
  task :load_cy => :environment do
    i = 1
    CSV.foreach(Rails.root.join('db', 'master_cy_lbm.csv'), :headers => true) do |row|
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{i=i+1}, #{row["code"]}"
      cy = CollectorYard.where(:code => row["code"]).first_or_initialize
      cy.name = row["name"]
      cy.district_name = row["district"]
      cy.sub_district_name = row["sub_district"]
      cy.longitude = row["X"].to_f
      cy.latitude = row["Y"].to_f
      cy.category = row["type"].downcase
      cy.save!
    end
  end
end
class Movement < ActiveRecord::Base
  enum category: [ :in, :out ]
  belongs_to :species_type

  scope :species_types, -> (species_types) { where("species_type_id IN (?)", species_types) }

  def self.autocomplete(keyword, source_type)
    if source_type == "cy_code"
      where("category = ? AND lower(source_code) LIKE lower(?)", 1, "%#{keyword}%").group("source_code")
    elsif source_type == "cy_sub_district"
      where("category = ? AND lower(source_sub_district_name) LIKE lower(?)", 1, "%#{keyword}%").group("source_sub_district_name")
    elsif source_type == "origin_district"
      where("category = ? AND lower(source_district_name) LIKE lower(?)", 0, "%#{keyword}%").group("source_district_name")
    end
  end

  def find_connections_by_source_type_and_destination_type(source_type, destination_type)
    category_field = 0
    keyword = ""
    keyword_field = "source_district_name"
    group_by_field = "destination_code"

    case source_type
    when "cy_code"
      category_field = 1
      keyword = self.source_code
      keyword_field = "source_code"
    when "cy_sub_district"
      category_field = 1
      keyword = self.source_sub_district_name
      keyword_field = "source_sub_district_name"
    when "origin_district"
      keyword = self.source_district_name
    end

    case destination_type
    when "cy_sub_districts"
      group_by_field = "destination_sub_district_name"
    when "cy_districts"
      group_by_field = "destination_district_name"
    end

    Movement.select("movements.*, SUM(weekly_volume) AS weekly_volumes, SUM(number_of_connectivity) AS number_of_connectivities").includes(:species_type).where("category = ? AND lower(#{keyword_field}) = lower(?)", category_field, keyword).group(group_by_field)
  end

  def self.to_csv(category_field)
    if category_field == "in" # movement in
      attributes = %w(movement_id origin_district destination_code destination_district destination_sub_district species number weekly_volume)
    else # movement out
      attributes = %w(movement_id origin_code origin_district origin_sub_district destination_LBM_CY_id destination_district destination_sub_district species number weekly_volume)
    end

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |m| # use .all here instead of .scoped due to API changes starting rails 4.1
        if category_field == "in"
          row = [
            m.id, # movement_id
            m.source_district_name, # origin_district
            m.destination_code, # destination_code
            m.destination_district_name, # destination_district
            m.destination_sub_district_name, # destination_sub_district
            m.species_type.code || "", # species
            m.number_of_connectivities, # number
            m.weekly_volumes # weekly_volume
          ]
        else
          row = [
            m.id, # movement_id
            m.source_code, # origin_code
            m.source_district_name, # origin_district
            m.source_sub_district_name, # origin_sub_district
            m.destination_code, # destination_LBM_CY_id
            m.destination_district_name, # destination_district
            m.destination_sub_district_name, # destination_sub_district
            m.species_type.code || "", # species
            m.number_of_connectivities, # number
            m.weekly_volumes # weekly_volume
          ]
        end
        csv << row
      end
    end
  end
end

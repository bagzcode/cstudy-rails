class Movement < ActiveRecord::Base
  enum category: [ :in, :out ]

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
    group_by_field = ""

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

    select("*, SUM(weekly_volume) AS weekly_volumes, SUM(number_of_connectivity) AS number_of_connectivities").where("category = ? AND lower(#{keyword_field}) LIKE lower(?)", 0, "%#{keyword}%").group(group_by_field)
  end
end

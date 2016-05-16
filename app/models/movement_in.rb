class MovementIn < ActiveRecord::Base
  belongs_to :species_type
  belongs_to :collector_type

  scope :by_species_types, -> species_types { where("species_type_id in (?)", species_types) }
  scope :by_collector_types, -> collector_types { where("collector_type_id in (?)", collector_types) }
  scope :distance_from, -> distance_from { where("in_km_distance_origin_district_destination >= ?", distance_from.to_i) }
  scope :distance_to, -> distance_to { where("in_km_distance_origin_district_destination <= ?", distance_to.to_i) }
  scope :weekly_volume_from, -> weekly_volume_from { having("sum(weekly_volume) >= ?", weekly_volume_from.to_i) }
  scope :weekly_volume_to, -> weekly_volume_to { having("sum(weekly_volume) <= ?", weekly_volume_to.to_i) }
  scope :by_destination_codes, -> destination_codes { where("destination_ids in (?)", destination_codes) }
  scope :by_origin_district, -> origin_district { where("lower(origin_district) LIKE lower(?)", origin_district) }

  def self.apply_scopes(species_types, collector_types, distance_from, distance_to, weekly_volume_from, weekly_volume_to)
    movements = select("destination_code")
    movements = movements.by_species_types(species_types) if species_types.present?
    movements = movements.by_collector_types(collector_types) if collector_types.present?
    movements = movements.distance_from(distance_from) if distance_from.present?
    movements = movements.distance_to(distance_to) if distance_to.present?
    movements = movements.group("destination_code")
    movements = movements.weekly_volume_from(weekly_volume_from) if weekly_volume_from.present?
    movements = movements.weekly_volume_to(weekly_volume_to) if weekly_volume_to.present?

    where("destination_code in (?)", movements.map(&:destination_code))
  end

  def self.select_all_origins
    select.("origin_district").group("origin_district")
  end

  def self.select_all_destinations
    select("destination_code,
            destination_name,
            destination_x,
            destination_y,
            destination_district,
            destination_subdistrict,
            point_x_subdistrict_destination,
            point_y_subdistrict_destination,
            object_id_subdistrict_destination,
            destination_in_cluster,
            destination_cluster_name").group("destination_code")
  end

  # def self.apply_scopes_with_destination_code(species_types, collector_types, distance_from, distance_to, weekly_volume_from, weekly_volume_to, destination_code)
  #   movements = select("destination_code")
  #   movements = movements.by_species_types(species_types) if species_types.present?
  #   movements = movements.by_collector_types(collector_types) if collector_types.present?
  #   movements = movements.distance_from(distance_from) if distance_from.present?
  #   movements = movements.distance_to(distance_to) if distance_to.present?
  #   movements = movements.group("destination_code")
  #   movements = movements.weekly_volume_from(weekly_volume_from) if weekly_volume_from.present?
  #   movements = movements.weekly_volume_to(weekly_volume_to) if weekly_volume_to.present?

  #   movements.where("lower(destination_code) LIKE lower(?)", destination_code)
  # end
end

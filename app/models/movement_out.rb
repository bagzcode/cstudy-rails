class MovementOut < ActiveRecord::Base
  belongs_to :species_type
  belongs_to :collector_type

  has_many :movement_ins, primary_key: 'origin_code', foreign_key: 'destination_code'

  scope :by_species_types, -> species_types { where("movement_outs.species_type_id in (?)", species_types) }
  scope :by_collector_types, -> collector_types { where("movement_outs.collector_type_id in (?)", collector_types) }
  scope :collector_distance_from, -> collector_distance_from { where("movement_outs.in_km_distance_origin_destination >= ?", collector_distance_from.to_i) }
  scope :collector_distance_to, -> collector_distance_to { where("movement_outs.in_km_distance_origin_destination <= ?", collector_distance_to.to_i) }
  scope :weekly_volume_from, -> weekly_volume_from { having("sum(movement_outs.weekly_volume) >= ?", weekly_volume_from.to_i) }
  scope :weekly_volume_to, -> weekly_volume_to { having("sum(movement_outs.weekly_volume) <= ?", weekly_volume_to.to_i) }
  scope :by_destination_codes, -> destination_codes { where("movement_outs.destination_ids in (?)", destination_codes) }
  scope :by_origin_codes, -> origin_codes { where("movement_outs.origin_code in (?)", origin_codes) }

  # scope :origin_distance_from, -> origin_distance_from { where("movement_ins.in_km_distance_origin_district_destination >= ?", origin_distance_from.to_i) }
  # scope :origin_distance_to, -> origin_distance_to { where("movement_ins.in_km_distance_origin_district_destination <= ?", origin_distance_to.to_i) }

  def self.apply_scopes(species_types, collector_types, collector_distance_from, collector_distance_to, weekly_volume_from, weekly_volume_to)
    movements = select("origin_code")
    movements = movements.by_species_types(species_types) if species_types.present?
    movements = movements.by_collector_types(collector_types) if collector_types.present?
    movements = movements.collector_distance_from(collector_distance_from) if collector_distance_from.present?
    movements = movements.collector_distance_to(collector_distance_to) if collector_distance_to.present?
    movements = movements.group("origin_code")
    movements = movements.weekly_volume_from(weekly_volume_from) if weekly_volume_from.present?
    movements = movements.weekly_volume_to(weekly_volume_to) if weekly_volume_to.present?

    movements
  end

  def self.select_all_origins
    select("origin_code,
            origin_name,
            origin_district,
            origin_sub_district,
            origin_x,
            origin_y").group("origin_code")
  end

  def self.select_all_destinations
    select("name_destination,
            destination_lbm_cy_id,
            destination_district,
            destination_sub_district,
            destination_x_original,
            destination_y_original,
            xy,
            point_x_subdistrict,
            point_y_subdistrict,
            object_id_destination,
            in_km_distance_origin_destination,
            origin_in_cluster,
            cluster_name,
            destination_code").group("destination_code")
  end

  # def self.apply_scopes(species_types, collector_types, collector_distance_from, collector_distance_to, weekly_volume_from, weekly_volume_to, origin_distance_from, origin_distance_to)
  #   movements = select("origin_code")
  #   movements = movements.by_species_types(species_types) if species_types.present?
  #   movements = movements.by_collector_types(collector_types) if collector_types.present?
  #   movements = movements.collector_distance_from(collector_distance_from) if collector_distance_from.present?
  #   movements = movements.collector_distance_to(collector_distance_to) if collector_distance_to.present?
  #   movements = movements.group("origin_code")
  #   movements = movements.weekly_volume_from(weekly_volume_from) if weekly_volume_from.present?
  #   movements = movements.weekly_volume_to(weekly_volume_to) if weekly_volume_to.present?

  #   joins(:movement_ins).where("origin_code in (?)", movements.map(&:origin_code))

  #   movements = movements.origin_distance_from(origin_distance_from) if origin_distance_from.present?
  #   movements = movements.origin_distance_to(origin_distance_to) if origin_distance_to.present?
  # end
end

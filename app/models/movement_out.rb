class MovementOut < ActiveRecord::Base
  belongs_to :species_type
  belongs_to :collector_type

  has_many :movement_ins, primary_key: 'origin_code', foreign_key: 'destination_code'

  scope :by_species_types, -> species_types { where("movement_outs.species_type_id in (?)", species_types) }
  scope :by_collector_types, -> collector_types { where("movement_outs.collector_type_id in (?)", collector_types) }
  scope :by_collector_distance_from, -> collector_distance_from { where("movement_outs.in_km_distance_origin_destination >= ?", collector_distance_from.to_f) }
  scope :by_collector_distance_to, -> collector_distance_to { where("movement_outs.in_km_distance_origin_destination <= ?", collector_distance_to.to_f) }
  scope :by_destination_weekly_volume_from, -> weekly_volume_from { having("sum(movement_outs.weekly_volume) >= ?", weekly_volume_from.to_f) }
  scope :by_destination_weekly_volume_to, -> weekly_volume_to { having("sum(movement_outs.weekly_volume) <= ?", weekly_volume_to.to_f) }
  scope :by_destination_codes, -> destination_codes { where("movement_outs.destination_ids in (?)", destination_codes) }
  scope :by_origin_codes, -> origin_codes { where("movement_outs.origin_code in (?)", origin_codes) }

  # scope :origin_distance_from, -> origin_distance_from { where("movement_ins.in_km_distance_origin_district_destination >= ?", origin_distance_from.to_f) }
  # scope :origin_distance_to, -> origin_distance_to { where("movement_ins.in_km_distance_origin_district_destination <= ?", origin_distance_to.to_f) }

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

  def self.apply_scopes(movement_types, species_types, origin_collector_types, destination_collector_types, origin_distance_from, origin_distance_to, collector_distance_from, collector_distance_to, origin_weekly_volume_from, origin_weekly_volume_to, destination_weekly_volume_from, destination_weekly_volume_to)
    query = select("
      movement_ins.origin_district AS origin_district,
      movement_outs.origin_code AS source_code,
      movement_outs.destination_code AS destination_code,
      movement_outs.destination_sub_district AS destination_sub_district,
      movement_outs.destination_district AS destination_district,
      movement_outs.in_km_distance_origin_destination,
      movement_ins.in_km_distance_origin_district_destination,
      SUM(movement_ins.weekly_volume) AS weekly_volume_in,
      SUM(movement_outs.weekly_volume) AS weekly_volume_out
    ").joins("LEFT OUTER JOIN movement_ins ON movement_ins.destination_code = movement_outs.origin_code")

    # if origin_collector_types.present? or destination_collector_types.present? or collector_distance_from.present? or collector_distance_to.present? or origin_weekly_volume_from.present? or origin_weekly_volume_to.present?
    #   query = query.joins("LEFT OUTER JOIN movement_ins ON movement_ins.destination_code = movement_outs.origin_code")
    # end

    # species types
    query = query.by_species_types(species_types) if species_types.present?

    # collector_types (out)
    query = query.where("movement_ins.collector_type_id in (?)", origin_collector_types) if origin_collector_types.present?

    # collector_types (in)
    query = query.where("movement_outs.collector_type_id in (?)", destination_collector_types) if destination_collector_types.present?

    # collector_distance (out)
    query = query.by_collector_distance_from(collector_distance_from) if collector_distance_from.present?
    query = query.by_collector_distance_to(collector_distance_to) if collector_distance_to.present?

    # origin_distance (in)
    query = query.where("movement_ins.in_km_distance_origin_district_destination >= ?", origin_distance_from.to_f) if origin_distance_from.present?
    query = query.where("movement_ins.in_km_distance_origin_district_destination <= ?", origin_distance_to.to_f) if origin_distance_to.present?

    # origin_weekly_volume (in)
    query = query.having("sum(movement_ins.weekly_volume) >= ?", origin_weekly_volume_from.to_f) if origin_weekly_volume_from.present?
    query = query.having("sum(movement_ins.weekly_volume) <= ?", origin_weekly_volume_to.to_f) if origin_weekly_volume_to.present?

    # destination_weekly_volume (out)
    query = query.by_destination_weekly_volume_from(destination_weekly_volume_from) if destination_weekly_volume_from.present?
    query = query.by_destination_weekly_volume_to(destination_weekly_volume_to) if destination_weekly_volume_to.present?

    # group by depends on movement_types
    #group_by_columns = ["movement_outs.origin_code"]
    #group_by_columns << "movement_ins.origin_district" if movement_types.present? and movement_types.include? "in"

    query = query.group("movement_outs.origin_code, movement_ins.origin_district")
  end
end

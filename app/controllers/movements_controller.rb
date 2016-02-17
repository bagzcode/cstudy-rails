class MovementsController < ApplicationController
  has_scope :autocomplete, :using => [:keyword, :source_type], :type => :hash
  # has_scope :species_types, :type => :array

  respond_to :json, :js

  def index
    @movements = apply_scopes(Movement).all
    respond_with(@movements)
  end

  def show
    @movement = Movement.find(params[:id])
    @connections = @movement.find_connections_by_source_type_and_destination_type(params[:source_type], params[:destination_type])
    respond_to do |format|
      format.csv { send_data @connections.to_csv(@movement.category), filename: "connections.csv" }
    end
  end

  def results
    @movement_ins = MovementIn
    @movement_outs = MovementOut

    if params[:species_types]
      @movement_ins.where("species_type_id IN (?)", params[:species_types])
      @movement_outs.where("species_type_id IN (?)", params[:species_types])
    end

    if params[:collector_types]
      @movement_ins.where("collector_type_id IN (?)", params[:collector_types])
      @movement_outs.where("collector_type_id IN (?)", params[:collector_types])
    end

    if params[:weekly_volume][:from]
      @movement_ins.where("weekly_volume >= ?", params[:weekly_volume][:from])
      @movement_outs.where("weekly_volume >= ?", params[:weekly_volume][:from])
    end

    if params[:weekly_volume][:to]
      @movement_ins.where("weekly_volume <= ?", params[:weekly_volume][:to])
      @movement_outs.where("weekly_volume <= ?", params[:weekly_volume][:to])
    end

    if params[:distance][:from]
      @movement_ins.where("distance >= ?", params[:distance][:from])
      @movement_outs.where("distance >= ?", params[:distance][:from])
    end

    if params[:distance][:to]
      @movement_ins.where("distance <= ?", params[:distance][:to])
      @movement_outs.where("distance <= ?", params[:distance][:to])
    end

    # @movement_ins.group("origin_code")
    # @movement_outs.group("")

    respond_to do |format|
      format.js { render layout: false }
    end
  end
end

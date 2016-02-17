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

    # if params[:weekly_volume][:from]
    #   @movement_ins.where("weekly_volume >= ?", params[:weekly_volume][:from])
    #   @movement_outs.where("weekly_volume >= ?", params[:weekly_volume][:from])
    # end

    # if params[:weekly_volume][:to]
    #   @movement_ins.where("weekly_volume <= ?", params[:weekly_volume][:to])
    #   @movement_outs.where("weekly_volume <= ?", params[:weekly_volume][:to])
    # end

    # if params[:distance][:from]
    #   @movement_ins.where("distance >= ?", params[:distance][:from])
    #   @movement_outs.where("distance >= ?", params[:distance][:from])
    # end

    # if params[:distance][:to]
    #   @movement_ins.where("distance <= ?", params[:distance][:to])
    #   @movement_outs.where("distance <= ?", params[:distance][:to])
    # end

    # default group_by, the field 'code' has been set if collector code is missing,
    # it uses sub district name and district name concatenated, or if sub district is missing,
    # then it uses only district.
    @movement_ins.group("code")
    @movement_outs.group("code")

    # TODO: Probably add 'HAVING' clause here based in weekly_volume and distance summary

    respond_to do |format|
      format.js { render layout: false }
    end
  end
end

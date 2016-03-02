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
    @movement_outs = MovementOut.apply_scopes(params[:species_types],
                                            params[:collector_types],
                                            params[:collector_distance][:from],
                                            params[:collector_distance][:to],
                                            params[:weekly_volume][:from],
                                            params[:weekly_volume][:to]).eager_load(:movement_ins)

    respond_to do |format|
      format.js { render layout: false }
    end
  end
end

class MapController < ApplicationController
  def index
  end

  def movement_in
    # send_data File.read(Rails.root.join("db", "movement_in_new.csv"))
    render json: MovementIn.select_all_destinations # select all collectors from table movement_ins
  end

  def movement_out
    # send_data File.read(Rails.root.join("db", "movement_out_new.csv"))
    render json: MovementOut.select_all_origins # select all collectors from table movement_outs
  end

  def collector_yards
    send_data File.read(Rails.root.join("db", "master_cy_lbm.csv"))
  end
end

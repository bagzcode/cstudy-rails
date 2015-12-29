class MapController < ApplicationController
  def index
  end

  def movement_in
    send_data File.read(Rails.root.join("db", "movement_in.csv"))
  end

  def movement_out
    send_data File.read(Rails.root.join("db", "movement_out.csv"))
  end

  def collector_yards
    send_data File.read(Rails.root.join("db", "master_cy_lbm.csv"))
  end
end

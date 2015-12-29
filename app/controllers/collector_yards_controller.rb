class CollectorYardsController < ApplicationController
  respond_to :json

  def index
    @collector_yards = CollectorYards.all
    respond_with(@collector_yards)
  end
end

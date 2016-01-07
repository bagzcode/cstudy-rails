class MovementsController < ApplicationController
  has_scope :autocomplete, :using => [:keyword, :source_type], :type => :hash

  respond_to :json

  def index
    @movements = apply_scopes(Movement).all
    respond_with(@movements)
  end
end

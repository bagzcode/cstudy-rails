class MovementOutsController < ApplicationController
  has_scope :autocomplete, :using => [:keyword, :source_type], :type => :hash
  respond_to :json, :js

  def index
    @movement_outs = apply_scopes(MovementOut).all
    respond_with(@movement_outs)
  end
end

class MovementsController < ApplicationController
  has_scope :species_types, type: :array
  has_scope :source_type
  has_scope :destination_type
  has_scope :source_code
  has_scope :source_district
  has_scope :source_sub_district

  def index

  end
end

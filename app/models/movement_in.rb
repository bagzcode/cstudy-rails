class MovementIn < ActiveRecord::Base
  belongs_to :species_type
  belongs_to :collector_type
end

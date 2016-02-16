class MovementOut < ActiveRecord::Base
  belongs_to :species_type
  belongs_to :collector_type
end

class SpeciesType < ActiveRecord::Base
  has_many :movements
  has_many :movement_ins
  has_many :movement_outs
end

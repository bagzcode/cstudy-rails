class CollectorType < ActiveRecord::Base
  has_many :movement_ins
  has_many :movement_outs
end

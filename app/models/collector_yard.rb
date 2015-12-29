class CollectorYard < ActiveRecord::Base
  enum category: [ :cy, :lbm ]
end

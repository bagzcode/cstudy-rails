class Movement < ActiveRecord::Base
  enum category: [ :in, :out ]
end

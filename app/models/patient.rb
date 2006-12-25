class Patient < ActiveRecord::Base
  has_many :encounters
end

class Privilege < ActiveRecord::Base
  has_many :users
end

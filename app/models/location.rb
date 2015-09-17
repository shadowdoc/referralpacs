class Location < ActiveRecord::Base
  has_many :encounters

  attr_accessible :name

  validates_presence_of :name
  validates_uniqueness_of :name

end

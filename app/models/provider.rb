class Provider < User
  unloadable
  has_many :encounters
  has_many :quality_checks
end
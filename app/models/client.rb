
class Client < User
  unloadable
  has_many :encounters
end

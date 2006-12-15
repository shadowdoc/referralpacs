class Refusers < ActiveRecord::Base
  validates_presence_of :username :password :email :access_id :provider_created :user_created
end

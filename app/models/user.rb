require "digest/md5"
  
class User < ActiveRecord::Base

  attr_accessor :password
  attr_accessible :email, :password
  
  validates_uniqueness_of :email
  validates_presence_of :email, :password
  
  def before_create
    self.hashedpassword = User.hash_password(self.password)
  end
  
  def after_create
    @password = nil
  end

  private
  def self.hash_password(password)
    Digest::MD5.hexdigest(password)
  end
  
end

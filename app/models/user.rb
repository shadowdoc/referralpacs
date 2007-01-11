require "digest/md5"
  
class User < ActiveRecord::Base

  attr_accessor :password
  attr_accessible :email, :password, :name, :privilege_id
  
  validates_uniqueness_of :email
  validates_presence_of :email, :password, :name
  
  before_destroy :dont_destroy_marc
  belongs_to :privilege
    
  def before_create
    self.hashed_password = User.hash_password(self.password)
  end
  
  def after_create
    self.password = nil
  end
  
  def before_update
    self.hashed_password = User.hash_password(self.password)
  end
  
  def after_update
    self.password = nil
  end
  
  def self.login(email, password)
    hashed_password = hash_password(password || "")
    find(:first,
         :conditions => ["email = ? and hashed_password = ?", email, hashed_password])
  end
  
  def try_to_login()
    User.login(self.email, self.password)
  end
  
  private
  def self.hash_password(password)
    Digest::MD5.hexdigest(password)
  end
  
  def dont_destroy_marc
    raise "Can't destroy mkohli@iupui.edu" if self.email == 'mkohli@iupui.edu'
  end
  
end

class Provider < User
  attr_accessible :title
end

class Client < User
  attr_accessible :contact
end

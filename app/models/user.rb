require 'md5'
require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :moderatorships, :dependent => :destroy
  has_many :forums, :through => :moderatorships, :order => 'forums.name'
  has_many :phrases
  has_many :posts
  validates_presence_of     :login, :email, :password
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  # names that start with #s really upset me for some reason
  validates_format_of       :login, :with => /^[a-zA-Z]{2}(?:\w+)?$/
  validates_length_of       :login, :minimum => 2
  
  # names that start with #s really upset me for some reason
  #  validates_format_of     :display_name, :with => /^[a-zA-Z]{2}(?:[.'\w ]+)?$/
  validates_uniqueness_of :display_name, :case_sensitive => false
  
  validates_confirmation_of :password
  validates_length_of       :password, :minimum => 5
  before_validation { |u| u.display_name = u.login if u.display_name.blank? }
  # first user becomes admin automatically
  before_create { |u| u.admin = true if User.count == 0 }
  
  before_save :hash_password
  
  attr_protected :admin, :posts_count, :login, :created_at, :updated_at, :last_login_at, :topics_count
  
  def self.currently_online
    user_ids = Session.find(:all, :select => "user_id", :conditions => ["user_id is NOT NULL and sessions.updated_at > ?", Time.now.utc-5.minutes]).map(&:user_id).uniq
    User.find(user_ids)
  end
  
  def reset_login_key!
    self.login_key = MD5.md5(Time.now.to_s + password + rand(123456789).to_s).to_s
    # this is not currently honored
    self.login_key_expires_at = Time.now.utc+1.year
    save!
    login_key
  end
  
  def moderator_of?(forum)
    moderatorships.count(:all, :conditions => ['forum_id = ?', (forum.is_a?(Forum) ? forum.id : forum)]) == 1
  end
  
  def good_karma_count
    attributes['good_karma_count'] ||= 0
  end
  
  def update_karma
    karma = Karma.count_good_karma_by_user(self)
    self.update_attribute(:good_karma_count, karma)
    self.good_karma_count = karma  
  end
  
  def hash_password
    write_attribute("password", User.hashed(self.password)) if self.password_confirmation && self.password_confirmation != ""
  end
  
  def self.hashed(str)
    return Digest::SHA1.hexdigest("rubyonbr.org--#{str}--}")[0..39]
  end
  
  def self.find_and_valid(login, password)
    User.find_by_login_and_password(login, User.hashed(password))
  end
  
  def up_pass
    if self.pass_ok.nil?
      self.password_confirmation = self.password
      self.pass_ok = 0
      self.save!
    end
  end
  
end

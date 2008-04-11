class Post < ActiveRecord::Base
  belongs_to :forum, :counter_cache => true
  belongs_to :user,  :counter_cache => true
  belongs_to :topic, :counter_cache => true 
  
  before_create { |r| r.forum_id = r.topic.forum_id }
  before_save   { |r| r.body.strip! }
  after_create  { |r| Topic.update_all(['replied_at = ?', Time.now.utc], ['id = ?', r.topic_id]) }

  validates_presence_of :user, :body
  attr_accessible :body
  
  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(topic.forum_id))
  end
end

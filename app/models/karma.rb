class Karma < ActiveRecord::Base

  belongs_to :user
  belongs_to :post, :include => 'user'

  after_save :update_karma
  after_destroy :update_karma

  def self.count_good_karma_by_user(user)
    id = user.is_a?(User) ? user.id : user.to_i
    count(:include => 'post', :conditions => ['posts.user_id = ? and value = 1', id])
  end

  def self.create_good_karma(user, post)
    Karma.create(:user => user, :post => post, :value => 1)
  end

  def self.remove_karma(user, post)
    karma = Karma.find_by_user_id_and_post_id(user.id, post.id)
    karma.destroy
  end

  def self.update_all_karmas
    User.find(:all).each do |user|
      user.update_karma
    end
  end

  protected
  def update_karma
    self.post.user.update_karma
  end
  
end
class AddIndexesForPerformance < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_index :posts, :forum_id
      add_index :posts, :user_id
      add_index :posts, :topic_id
      add_index :topics, :forum_id
      add_index :topics, :user_id
      add_index :sessions, :session_id
      add_index :sessions, :updated_at
      add_index :sessions, :user_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_index :posts, :forum_id
      remove_index :posts, :user_id
      remove_index :posts, :topic_id
      remove_index :topics, :forum_id
      remove_index :topics, :user_id
      remove_index :sessions, :session_id
      remove_index :sessions, :updated_at
      remove_index :sessions, :user_id
    end
  end
end

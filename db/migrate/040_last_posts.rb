class LastPosts < ActiveRecord::Migration
  def self.up
    create_table :last_posts do |t|
      t.column :topic_id, :integer
      t.column :forum_id, :integer
      t.column :post_id,:integer
      t.column :user_id, :integer
      
      
    end
    
    
  end

  def self.down
    drop_table :last_posts
  end
end

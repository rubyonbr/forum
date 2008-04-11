class DropLastPosts < ActiveRecord::Migration
  def self.up
    drop_table :last_posts
  end

  def self.down
  end
end

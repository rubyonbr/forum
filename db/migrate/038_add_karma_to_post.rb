class AddKarmaToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :good_karma_count, :integer, :default => 0
    add_column :posts, :bad_karma_count, :integer, :default => 0
  end

  def self.down
    remove_column :posts, :good_karma_count
    remove_column :posts, :bad_karma_count
  end
end

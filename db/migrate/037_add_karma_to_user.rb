class AddKarmaToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :good_karma_count, :integer, :default => 0
  end

  def self.down
    remove_column :users, :good_karma_count
  end
end

class AddLinkToAvatarInUser < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar, :string
  end

  def self.down
    remove_column :users, :avatar, :string
  end
end

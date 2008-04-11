class AddRestrictToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :restricted, :boolean
  end

  def self.down
    remove_column :blogs, :restricted
  end
end

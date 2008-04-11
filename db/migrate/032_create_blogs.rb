class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.column :url, :string
      t.column :rss, :string
      t.column :author, :string
      t.column :avatar, :string
      t.column :comment_expression, :string
    end
  end

  def self.down
    drop_table :blogs
  end
end

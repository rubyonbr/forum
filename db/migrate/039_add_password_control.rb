class AddPasswordControl < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :users, :pass_ok, :integer, :default => 0
      User.find(:all).each { |it| it.up_pass }
    end
  end

  def self.down
    remove_column :users, :pass_ok
  end
end

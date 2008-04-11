class CreateConfigurations < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :configurations do |t|
        t.column :name, :string
        t.column :value, :string
      end
      add_index :configurations, :name
    end
  end

  def self.down
    drop_table :configurations
  end
end

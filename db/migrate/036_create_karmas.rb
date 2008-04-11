class CreateKarmas < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :karmas do |t|
        t.column :user_id, :integer
        t.column :post_id, :integer
        t.column :value, :integer
        t.column :created_at, :datetime
      end
      
      add_index :karmas, :user_id
      add_index :karmas, :post_id
      add_index :karmas, [:user_id, :post_id], :unique
    end
  end

  def self.down
    drop_table :karmas
  end
end

class CreatePhrases < ActiveRecord::Migration
  def self.up
    create_table :phrases do |t|
      t.column :text, :string, :limit => 255
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :phrases
  end
end

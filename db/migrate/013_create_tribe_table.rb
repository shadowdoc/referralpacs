class CreateTribeTable < ActiveRecord::Migration
  def self.up
    create_table :tribes  do |t|
      t.column :name, :string
    end
    
    rename_column :patients, "tribe", "tribe_id"
    
  end

  def self.down
    drop_table :tribes
    rename_column :patients, "tribe_id", "tribe"
  end
  
end

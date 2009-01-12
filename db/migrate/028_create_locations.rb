class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.column :name, :string
      t.timestamps
    end
    
    add_column :encounters, :location_id, :integer
    
  end

  def self.down
    drop_table :locations
    
    remove_column :encounters, :location_id
  end
end

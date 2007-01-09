class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :path, :string
      t.column :encounter_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :images
  end
end

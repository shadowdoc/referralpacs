class CreateConcepts < ActiveRecord::Migration
  def self.up
    create_table :concepts do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :created_by, :integer
      t.column :created_at, :datetime
      t.column :updated_by, :integer
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :concepts
  end
end

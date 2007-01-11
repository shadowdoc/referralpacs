class AddImageExtension < ActiveRecord::Migration
  def self.up
    add_column :images, :extension, :string, :limit => 5, :default => 'jpg'
  end

  def self.down
    remove_column :images, :extension
  end
end

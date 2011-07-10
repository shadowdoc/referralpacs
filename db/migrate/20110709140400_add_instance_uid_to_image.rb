class AddInstanceUidToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :instance_uid, :string
  end

  def self.down
    remove_column :images, :string
  end
end

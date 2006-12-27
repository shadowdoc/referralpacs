class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "name",            :string
      t.column "hashed_password", :string
      t.column "email",           :string
      t.column "access_level_id", :integer
      t.column "provider_id",     :integer
      t.column "created_by",      :integer
      t.column "created_at",      :datetime
      t.column "updated_by",      :integer
      t.column "updated_at",      :datetime
    end
  end

  def self.down
    drop_table :users
  end
end

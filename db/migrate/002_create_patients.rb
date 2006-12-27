class CreatePatients < ActiveRecord::Migration
  def self.up
    create_table :patients do |t|
      t.column "mrn_ampath",             :integer
      t.column "national_identifier",    :integer
      t.column "prefix",                 :string
      t.column "given_name",             :string
      t.column "middle_name",            :string
      t.column "family_name",            :string
      t.column "last_name_prefix",       :string
      t.column "gender",                 :string
      t.column "race",                   :string
      t.column "tribe",                  :integer
      t.column "address1",               :string
      t.column "address2",               :string
      t.column "created_by",             :integer
      t.column "created_at",             :datetime
      t.column "updated_by",             :integer
      t.column "updated_at",             :datetime
    end
  end

  def self.down
    drop_table :patients
  end
end

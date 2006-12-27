class AddEncounters < ActiveRecord::Migration
  def self.up
    create_table :encounters do |t|
      t.column  :date,        :datetime
      t.column  :patient_id,  :integer
      t.column  :indication,  :string
      t.column  :findings,    :string
      t.column  :impression,  :string
      t.column  :created_by,  :integer
      t.column  :created_at,  :datetime
      t.column  :updated_by,  :integer
      t.column  :updated_at,  :datetime
    end
  end

  def self.down
    drop_table :encounters
  end

end

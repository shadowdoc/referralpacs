class CreateQualityChecks < ActiveRecord::Migration
  def self.up
    create_table :quality_checks do |t|
      t.string :score
      t.string :status
      t.text :comment
      t.references :encounter
      t.references :provider
      t.references :reviewer

      t.timestamps
    end
  end

  def self.down
    drop_table :quality_checks
  end
end

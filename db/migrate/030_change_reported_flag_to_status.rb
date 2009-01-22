class ChangeReportedFlagToStatus < ActiveRecord::Migration
  def self.up
    rename_column :encounters, :reported, :status
    change_column :encounters, :status, :string
    
    Encounter.reset_column_information
    say_with_time "Updating encounters" do
      encounters = Encounter.find(:all)
      encounters.each do |e|
        e.status = "archived"
        e.save
        say "#{e.id} updated!", true
      end
    end
  end

  def self.down
    # Because this migration changes existing data it will be one-way.
    rename_column :encounters, :status, :reported
    change_column :encounters, :reported, :boolean
  end
end

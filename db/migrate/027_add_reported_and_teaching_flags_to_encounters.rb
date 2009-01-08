class AddReportedAndTeachingFlagsToEncounters < ActiveRecord::Migration
  def self.up
    add_column :encounters, 'reported', :boolean, :default => false
    add_column :encounters, 'teachingfile', :boolean, :default => false
    add_column :encounters, 'teachingfilereason', :string
    
    Encounter.reset_column_information
    
    say_with_time "Updating encounters" do

      Encounter.find(:all).each do |e|
        say "Updating Encounter #{e.id}", true
        if e.observations.length == 0 && e.impression == ""
          e.reported = false
        else
          e.reported = true
        end
        e.save
      end
    end
    
  end

  def self.down
    remove_column :encounters, 'reported'
    remove_column :encounters, 'teachingfile'
    remove_column :encounters, 'teachingfilereason'
  end
end

class AddOpenmrsVerifiedToPatientTable < ActiveRecord::Migration
  def self.up
    add_column :patients, 'openmrs_verified', :boolean, :default => false
    Patient.reset_column_information
    say_with_time "Updating patients" do
      patients = Patient.find(:all)
      patients.each do |p|
        p.update_attribute(:openmrs_verified, false)
        say "#{p.full_name} updated!", true
      end
    end
  end

  def self.down
    remove_column :patients, 'openmrs_verified'
  end

end

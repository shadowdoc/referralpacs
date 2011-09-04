class AddQualityControlPrivilege < ActiveRecord::Migration

  def self.up

    add_column :privileges, 'quality_control', :boolean

    Privilege.reset_column_information

    Privilege.find(:all).each do |priv|
      priv.quality_control = false
      priv.save
    end

    admin = Privilege.find_by_name("admin")
    admin.quality_control = true
    admin.save

    Privilege.new do |p|
      p.name = "super_radiologist"
      p.view_study =       true
      p.add_encounter =    true
      p.delete_encounter = false
      p.add_user =         false
      p.delete_user =      false
      p.update_user =      false
      p.add_patient =      false
      p.remove_patient =   false
      p.modify_encounter = true
      p.modify_patient =   false
      p.quality_control =  true
      p.save!
    end

  end

  def self.down
    remove_column :privileges, 'quality_control'
    Privilege.find(7).destroy
  end
end

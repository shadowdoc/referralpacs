class Dcm4cheePatient < ActiveRecord::Base

  establish_connection 'pacsdb'
  set_table_name 'patient'
  set_primary_key 'pk'

  has_many :dcm4chee_studies, :foreign_key => "patient_fk"

end
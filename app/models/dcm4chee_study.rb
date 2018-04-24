class Dcm4cheeStudy < ActiveRecord::Base

  establish_connection 'pacsdb'
  set_table_name 'study'
  set_primary_key 'pk'

  belongs_to :encounter, primary_key: 'study_uid', foreign_key: 'study_iuid'
  belongs_to :dcm4chee_patient, :foreign_key => 'patient_fk'
  has_many :dcm4chee_series, :foreign_key => 'study_fk'

end
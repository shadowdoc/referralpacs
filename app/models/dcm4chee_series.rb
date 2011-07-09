class Dcm4cheeSeries < ActiveRecord::Base

  establish_connection 'pacsdb'
  set_table_name 'series'
  set_primary_key 'pk'

  belongs_to  :dcm4chee_study, :foreign_key => "study_fk"
  has_many :dcm4chee_instances, :foreign_key => "series_fk"

end
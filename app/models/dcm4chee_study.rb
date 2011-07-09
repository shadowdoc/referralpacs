class Dcm4cheeStudy < ActiveRecord::Base
  establish_connection "pacsdb"
  set_table_name 'study'
  set_primary_key 'pk'

end
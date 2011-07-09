class Dcm4cheeInstance< ActiveRecord::Base

  establish_connection "pacsdb"
  set_table_name 'instance'
  set_primary_key 'pk'

  belongs_to  :dcm4chee_series, :foreign_key => "series_fk"

end
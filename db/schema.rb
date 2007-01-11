# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 10) do

  create_table "encounter_types", :force => true do |t|
    t.column "name",        :string
    t.column "modality",    :string
    t.column "created_at",  :datetime
    t.column "created_by",  :integer
    t.column "modified_at", :datetime
    t.column "modified_by", :integer
  end

  create_table "encounters", :force => true do |t|
    t.column "date",              :datetime
    t.column "patient_id",        :integer
    t.column "indication",        :string
    t.column "findings",          :string
    t.column "impression",        :string
    t.column "created_by",        :integer
    t.column "created_at",        :datetime
    t.column "updated_by",        :integer
    t.column "updated_at",        :datetime
    t.column "encounter_type_id", :integer
    t.column "provider_id",       :integer
    t.column "client_id",         :integer
  end

  create_table "images", :force => true do |t|
    t.column "path",         :string
    t.column "encounter_id", :integer
    t.column "created_at",   :datetime
    t.column "updated_at",   :datetime
    t.column "extension",    :string,   :limit => 5, :default => "jpg"
  end

  create_table "patients", :force => true do |t|
    t.column "mrn_ampath",          :integer
    t.column "national_identifier", :integer
    t.column "prefix",              :string
    t.column "given_name",          :string
    t.column "middle_name",         :string
    t.column "family_name",         :string
    t.column "last_name_prefix",    :string
    t.column "gender",              :string
    t.column "race",                :string
    t.column "tribe",               :integer
    t.column "address1",            :string
    t.column "address2",            :string
    t.column "created_by",          :integer
    t.column "created_at",          :datetime
    t.column "updated_by",          :integer
    t.column "updated_at",          :datetime
    t.column "birthdate",           :datetime
    t.column "mtrh_rad_id",         :integer
  end

  create_table "privileges", :force => true do |t|
    t.column "name",           :string
    t.column "view_study",     :boolean
    t.column "add_study",      :boolean
    t.column "remove_study",   :boolean
    t.column "add_patient",    :boolean
    t.column "remove_patient", :boolean
    t.column "add_user",       :boolean
    t.column "remove_user",    :boolean
  end

  create_table "users", :force => true do |t|
    t.column "name",            :string
    t.column "hashed_password", :string
    t.column "email",           :string
    t.column "provider_id",     :integer
    t.column "created_by",      :integer
    t.column "created_at",      :datetime
    t.column "updated_by",      :integer
    t.column "updated_at",      :datetime
    t.column "privilege_id",    :integer
    t.column "type",            :string
    t.column "title",           :string
    t.column "contact",         :string
  end

end

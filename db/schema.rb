# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20170831231714) do

  create_table "answers", :force => true do |t|
    t.integer "concept_id"
    t.integer "answer_id"
  end

  add_index "answers", ["answer_id"], :name => "answer_id_ix"
  add_index "answers", ["concept_id"], :name => "concept_id_ix"

  create_table "concepts", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "created_by"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.integer  "openmrs_id"
  end

  create_table "encounter_types", :force => true do |t|
    t.string   "name"
    t.string   "modality"
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "modified_at"
    t.integer  "modified_by"
  end

  create_table "encounters", :force => true do |t|
    t.datetime "date"
    t.integer  "patient_id"
    t.string   "indication"
    t.string   "findings"
    t.string   "impression"
    t.integer  "created_by"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.integer  "encounter_type_id"
    t.integer  "provider_id"
    t.integer  "client_id"
    t.integer  "xray_id"
    t.string   "status"
    t.boolean  "teachingfile",       :default => false
    t.string   "teachingfilereason"
    t.integer  "location_id"
    t.string   "study_uid"
    t.datetime "report_date"
  end

  add_index "encounters", ["patient_id"], :name => "patient_id_ix"
  add_index "encounters", ["report_date"], :name => "index_encounters_on_report_date"

  create_table "images", :force => true do |t|
    t.string   "path"
    t.integer  "encounter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extension",    :limit => 5, :default => "jpg"
    t.string   "instance_uid"
  end

  add_index "images", ["encounter_id"], :name => "encounter_id_ix"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "observations", :force => true do |t|
    t.integer  "encounter_id"
    t.integer  "question_concept_id"
    t.integer  "patient_id"
    t.float    "value_numeric"
    t.integer  "value_concept_id"
    t.boolean  "value_boolean"
    t.integer  "created_by"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
  end

  add_index "observations", ["encounter_id"], :name => "encounter_id_ix"

  create_table "patients", :force => true do |t|
    t.string   "mrn_ampath"
    t.integer  "national_identifier"
    t.string   "given_name"
    t.string   "middle_name"
    t.string   "family_name"
    t.string   "gender"
    t.integer  "tribe_id"
    t.string   "address1"
    t.string   "address2"
    t.integer  "created_by"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.datetime "birthdate"
    t.integer  "mtrh_rad_id"
    t.boolean  "birthdate_estimated"
    t.string   "city_village"
    t.string   "state_province"
    t.string   "country"
    t.boolean  "openmrs_verified",    :default => false
  end

  create_table "privileges", :force => true do |t|
    t.string  "name"
    t.boolean "view_study"
    t.boolean "add_encounter"
    t.boolean "delete_encounter"
    t.boolean "add_patient"
    t.boolean "remove_patient"
    t.boolean "add_user"
    t.boolean "delete_user"
    t.boolean "modify_patient"
    t.boolean "modify_encounter"
    t.boolean "merge_patients"
    t.boolean "update_user",      :default => false
    t.boolean "quality_control"
  end

  create_table "quality_checks", :force => true do |t|
    t.string   "score"
    t.string   "status"
    t.text     "comment"
    t.integer  "encounter_id"
    t.integer  "provider_id"
    t.integer  "reviewer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tribes", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "given_name"
    t.string   "hashed_password"
    t.string   "email"
    t.integer  "provider_id"
    t.integer  "created_by"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.integer  "privilege_id"
    t.string   "type"
    t.string   "title"
    t.string   "family_name"
    t.string   "api_key"
  end

  add_index "users", ["api_key"], :name => "index_users_on_api_key"

end

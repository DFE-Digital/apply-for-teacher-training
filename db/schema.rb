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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_01_150451) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "candidate_applications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.datetime "submitted_at"
    t.datetime "rejected_by_default_at"
  end

  create_table "contact_details", force: :cascade do |t|
    t.string "phone_number"
    t.string "email_address"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "degrees", force: :cascade do |t|
    t.string "type_of_degree"
    t.string "subject"
    t.string "institution"
    t.string "class_of_degree"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "personal_details", force: :cascade do |t|
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.string "preferred_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "qualifications", force: :cascade do |t|
    t.string "type_of_qualification"
    t.string "subject"
    t.string "institution"
    t.string "grade"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reject_by_default_timeframes", force: :cascade do |t|
    t.datetime "from_date", null: false
    t.datetime "to_date", null: false
    t.integer "number_of_working_days_until_rejection", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

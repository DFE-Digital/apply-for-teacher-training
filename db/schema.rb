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

ActiveRecord::Schema.define(version: 2019_08_29_223527) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "candidate_applications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
  end

  create_table "candidates", force: :cascade do |t|
    t.string "email_address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "magic_link_token"
    t.datetime "magic_link_token_sent_at"
    t.index ["email_address"], name: "index_candidates_on_email_address", unique: true
    t.index ["magic_link_token"], name: "index_candidates_on_magic_link_token", unique: true
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

end

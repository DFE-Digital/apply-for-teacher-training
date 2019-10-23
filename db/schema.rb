# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_23_151050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "application_choices", id: :string, limit: 10, force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.text "personal_statement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", null: false
    t.json "offer"
    t.string "rejection_reason"
    t.bigint "course_option_id", null: false
    t.index ["application_form_id"], name: "index_application_choices_on_application_form_id"
    t.index ["course_option_id"], name: "index_application_choices_on_course_option_id"
  end

  create_table "application_forms", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_nationality"
    t.string "second_nationality"
    t.boolean "english_main_language"
    t.text "english_language_details"
    t.text "other_language_details"
    t.date "date_of_birth"
    t.boolean "further_information"
    t.text "further_information_details"
    t.datetime "submitted_at"
    t.string "support_reference", limit: 10
    t.index ["candidate_id"], name: "index_application_forms_on_candidate_id"
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

  create_table "course_options", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.bigint "course_id", null: false
    t.string "vacancy_status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_options_on_course_id"
    t.index ["site_id", "course_id"], name: "index_course_options_on_site_id_and_course_id", unique: true
    t.index ["site_id"], name: "index_course_options_on_site_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "level"
    t.date "start_date"
    t.index ["code"], name: "index_courses_on_code", unique: true
    t.index ["provider_id"], name: "index_courses_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_providers_on_code", unique: true
  end

  create_table "sites", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.bigint "provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code", "provider_id"], name: "index_sites_on_code_and_provider_id", unique: true
    t.index ["provider_id"], name: "index_sites_on_provider_id"
  end

  create_table "vendor_api_tokens", force: :cascade do |t|
    t.string "hashed_token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provider_id", null: false
    t.index ["hashed_token"], name: "index_vendor_api_tokens_on_hashed_token", unique: true
    t.index ["provider_id"], name: "index_vendor_api_tokens_on_provider_id"
  end

  add_foreign_key "application_choices", "application_forms", on_delete: :cascade
  add_foreign_key "application_choices", "course_options"
  add_foreign_key "application_forms", "candidates", on_delete: :cascade
  add_foreign_key "course_options", "courses", on_delete: :cascade
  add_foreign_key "course_options", "sites", on_delete: :cascade
  add_foreign_key "courses", "providers"
  add_foreign_key "sites", "providers"
  add_foreign_key "vendor_api_tokens", "providers", on_delete: :cascade
end

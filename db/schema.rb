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

ActiveRecord::Schema.define(version: 2020_02_12_152157) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "application_choices", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.text "personal_statement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", null: false
    t.json "offer"
    t.string "rejection_reason"
    t.bigint "course_option_id", null: false
    t.datetime "edit_by"
    t.datetime "reject_by_default_at"
    t.boolean "rejected_by_default", default: false, null: false
    t.integer "reject_by_default_days"
    t.datetime "decline_by_default_at"
    t.integer "decline_by_default_days"
    t.datetime "offered_at"
    t.datetime "rejected_at"
    t.datetime "withdrawn_at"
    t.datetime "declined_at"
    t.boolean "declined_by_default", default: false, null: false
    t.integer "offered_course_option_id"
    t.datetime "accepted_at"
    t.datetime "recruited_at"
    t.datetime "conditions_not_met_at"
    t.datetime "enrolled_at"
    t.string "offer_withdrawal_reason"
    t.datetime "offer_withdrawn_at"
    t.index ["application_form_id"], name: "index_application_choices_on_application_form_id"
    t.index ["course_option_id"], name: "index_application_choices_on_course_option_id"
  end

  create_table "application_experiences", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.string "type", null: false
    t.string "role", null: false
    t.string "organisation", null: false
    t.text "details", null: false
    t.boolean "working_with_children", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date"
    t.string "commitment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "working_pattern"
    t.index ["application_form_id"], name: "index_application_experiences_on_application_form_id"
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
    t.text "further_information"
    t.string "phone_number"
    t.string "address_line1"
    t.string "address_line2"
    t.string "address_line3"
    t.string "address_line4"
    t.string "country"
    t.string "postcode"
    t.datetime "submitted_at"
    t.string "support_reference", limit: 10
    t.string "disability_disclosure"
    t.string "uk_residency_status"
    t.boolean "work_history_completed", default: false, null: false
    t.text "work_history_explanation"
    t.boolean "degrees_completed", default: false, null: false
    t.text "becoming_a_teacher"
    t.text "subject_knowledge"
    t.text "interview_preferences"
    t.boolean "other_qualifications_completed", default: false, null: false
    t.boolean "disclose_disability"
    t.text "work_history_breaks"
    t.boolean "course_choices_completed", default: false, null: false
    t.boolean "volunteering_completed", default: false, null: false
    t.boolean "volunteering_experience"
    t.string "phase", default: "apply_1", null: false
    t.index ["candidate_id"], name: "index_application_forms_on_candidate_id"
  end

  create_table "application_qualifications", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.string "level", null: false
    t.string "qualification_type"
    t.string "subject"
    t.string "grade"
    t.boolean "predicted_grade"
    t.string "award_year"
    t.string "institution_name"
    t.string "institution_country"
    t.string "awarding_body"
    t.string "equivalency_details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "other_uk_qualification_type", limit: 100
    t.text "missing_explanation"
    t.index ["application_form_id"], name: "index_application_qualifications_on_application_form_id"
  end

  create_table "application_work_history_breaks", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.text "reason", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_form_id"], name: "index_application_work_history_breaks_on_application_form_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "candidates", force: :cascade do |t|
    t.string "email_address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "magic_link_token"
    t.datetime "magic_link_token_sent_at"
    t.boolean "hide_in_reporting", default: false, null: false
    t.integer "course_from_find_id"
    t.boolean "sign_up_email_bounced", default: false, null: false
    t.datetime "last_signed_in_at"
    t.index ["email_address"], name: "index_candidates_on_email_address", unique: true
    t.index ["magic_link_token"], name: "index_candidates_on_magic_link_token", unique: true
  end

  create_table "chasers_sent", force: :cascade do |t|
    t.string "chased_type", null: false
    t.bigint "chased_id", null: false
    t.string "chaser_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chased_type", "chased_id"], name: "index_chasers_sent_on_chased_type_and_chased_id"
  end

  create_table "course_options", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.bigint "course_id", null: false
    t.string "vacancy_status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "study_mode", default: "full_time", null: false
    t.index ["course_id"], name: "index_course_options_on_course_id"
    t.index ["site_id", "course_id", "study_mode"], name: "index_course_options_on_site_id_and_course_id_and_study_mode", unique: true
    t.index ["site_id"], name: "index_course_options_on_site_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "level"
    t.integer "accrediting_provider_id"
    t.boolean "exposed_in_find"
    t.boolean "open_on_apply", default: false, null: false
    t.integer "recruitment_cycle_year", null: false
    t.string "study_mode", limit: 1, default: "F", null: false
    t.index ["code"], name: "index_courses_on_code"
    t.index ["exposed_in_find", "open_on_apply"], name: "index_courses_on_exposed_in_find_and_open_on_apply"
    t.index ["provider_id", "code"], name: "index_courses_on_provider_id_and_code", unique: true
    t.index ["provider_id"], name: "index_courses_on_provider_id"
  end

  create_table "provider_agreements", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "provider_user_id", null: false
    t.string "agreement_type"
    t.datetime "accepted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider_id"], name: "index_provider_agreements_on_provider_id"
    t.index ["provider_user_id"], name: "index_provider_agreements_on_provider_user_id"
  end

  create_table "provider_users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "dfe_sign_in_uid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_signed_in_at"
    t.string "first_name"
    t.string "last_name"
    t.index ["dfe_sign_in_uid"], name: "index_provider_users_on_dfe_sign_in_uid"
    t.index ["email_address"], name: "index_provider_users_on_email_address", unique: true
  end

  create_table "provider_users_providers", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "provider_user_id", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["provider_id"], name: "index_provider_users_providers_on_provider_id"
    t.index ["provider_user_id"], name: "index_provider_users_providers_on_provider_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "sync_courses", default: false, null: false
    t.index ["code"], name: "index_providers_on_code", unique: true
  end

  create_table "references", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "feedback"
    t.bigint "application_form_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "relationship"
    t.string "hashed_sign_in_token"
    t.boolean "consent_to_be_contacted"
    t.string "feedback_status", default: "not_requested_yet", null: false
    t.jsonb "questionnaire"
    t.datetime "requested_at"
    t.boolean "replacement", default: false, null: false
    t.index ["application_form_id", "email_address"], name: "index_references_on_application_form_id_and_email_address", unique: true
    t.index ["application_form_id"], name: "index_references_on_application_form_id"
    t.index ["feedback_status"], name: "index_references_on_feedback_status"
  end

  create_table "sites", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.bigint "provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "address_line1"
    t.string "address_line2"
    t.string "address_line3"
    t.string "address_line4"
    t.string "postcode"
    t.index ["code", "provider_id"], name: "index_sites_on_code_and_provider_id", unique: true
    t.index ["provider_id"], name: "index_sites_on_provider_id"
  end

  create_table "support_users", force: :cascade do |t|
    t.string "dfe_sign_in_uid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email_address", null: false
    t.datetime "last_signed_in_at"
    t.string "first_name"
    t.string "last_name"
    t.index ["dfe_sign_in_uid"], name: "index_support_users_on_dfe_sign_in_uid", unique: true
    t.index ["email_address"], name: "index_support_users_on_email_address", unique: true
  end

  create_table "vendor_api_tokens", force: :cascade do |t|
    t.string "hashed_token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provider_id", null: false
    t.datetime "last_used_at"
    t.index ["hashed_token"], name: "index_vendor_api_tokens_on_hashed_token", unique: true
    t.index ["provider_id"], name: "index_vendor_api_tokens_on_provider_id"
  end

  create_table "vendor_api_users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email_address", null: false
    t.string "vendor_user_id", null: false
    t.bigint "vendor_api_token_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["full_name", "email_address", "vendor_user_id", "vendor_api_token_id"], name: "index_vendor_api_users_on_name_email_userid_token", unique: true
    t.index ["vendor_api_token_id"], name: "index_vendor_api_users_on_vendor_api_token_id"
  end

  add_foreign_key "application_choices", "application_forms", on_delete: :cascade
  add_foreign_key "application_choices", "course_options"
  add_foreign_key "application_choices", "course_options", column: "offered_course_option_id"
  add_foreign_key "application_experiences", "application_forms", on_delete: :cascade
  add_foreign_key "application_forms", "candidates", on_delete: :cascade
  add_foreign_key "application_qualifications", "application_forms", on_delete: :cascade
  add_foreign_key "application_work_history_breaks", "application_forms", on_delete: :cascade
  add_foreign_key "course_options", "courses", on_delete: :cascade
  add_foreign_key "course_options", "sites", on_delete: :cascade
  add_foreign_key "courses", "providers"
  add_foreign_key "provider_agreements", "provider_users"
  add_foreign_key "provider_agreements", "providers"
  add_foreign_key "references", "application_forms", on_delete: :cascade
  add_foreign_key "sites", "providers"
  add_foreign_key "vendor_api_tokens", "providers", on_delete: :cascade
end

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

ActiveRecord::Schema.define(version: 2020_07_21_125644) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "application_choices", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", null: false
    t.json "offer"
    t.string "rejection_reason"
    t.bigint "course_option_id", null: false
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
    t.datetime "sent_to_provider_at"
    t.text "structured_rejection_reasons"
    t.jsonb "withdrawal_feedback"
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
    t.jsonb "equality_and_diversity"
    t.text "safeguarding_issues"
    t.jsonb "satisfaction_survey"
    t.string "safeguarding_issues_status", default: "not_answered_yet", null: false
    t.integer "previous_application_form_id"
    t.boolean "personal_details_completed", default: false
    t.boolean "contact_details_completed", default: false
    t.boolean "english_gcse_completed", default: false
    t.boolean "maths_gcse_completed", default: false
    t.boolean "training_with_a_disability_completed", default: false
    t.boolean "safeguarding_issues_completed", default: false
    t.boolean "becoming_a_teacher_completed", default: false
    t.boolean "subject_knowledge_completed", default: false
    t.boolean "interview_preferences_completed", default: false
    t.boolean "references_completed", default: false
    t.boolean "science_gcse_completed", default: false
    t.datetime "edit_by"
    t.string "address_type", default: "uk", null: false
    t.string "international_address"
    t.string "right_to_work_or_study"
    t.string "right_to_work_or_study_details"
    t.boolean "efl_completed", default: false
    t.string "third_nationality"
    t.string "fourth_nationality"
    t.string "fifth_nationality"
    t.index ["candidate_id"], name: "index_application_forms_on_candidate_id"
    t.index ["submitted_at"], name: "index_application_forms_on_submitted_at"
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
    t.string "start_year"
    t.bigint "qualification_type_hesa_code"
    t.bigint "subject_hesa_code"
    t.bigint "institution_hesa_code"
    t.bigint "grade_hesa_code"
    t.boolean "international", default: false, null: false
    t.string "naric_reference"
    t.string "comparable_uk_degree"
    t.string "non_uk_qualification_type"
    t.string "comparable_uk_qualification"
    t.index ["application_form_id"], name: "index_application_qualifications_on_application_form_id"
    t.index ["grade_hesa_code"], name: "qualifications_by_grade_hesa_code"
    t.index ["institution_hesa_code"], name: "qualifications_by_institution_hesa_code"
    t.index ["qualification_type_hesa_code"], name: "qualifications_by_type_hesa_code"
    t.index ["subject_hesa_code"], name: "qualifications_by_subject_hesa_code"
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

  create_table "authentication_tokens", force: :cascade do |t|
    t.bigint "authenticable_id", null: false
    t.string "authenticable_type", null: false
    t.string "hashed_token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["authenticable_id", "authenticable_type"], name: "index_authentication_tokens_on_id_and_type"
    t.index ["hashed_token"], name: "index_authentication_tokens_on_hashed_token", unique: true
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
    t.boolean "site_still_valid", default: true, null: false
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
    t.boolean "exposed_in_find"
    t.boolean "open_on_apply", default: false, null: false
    t.integer "recruitment_cycle_year", null: false
    t.string "study_mode", limit: 1, default: "F", null: false
    t.string "financial_support"
    t.datetime "start_date"
    t.string "course_length"
    t.string "description"
    t.integer "accredited_provider_id"
    t.jsonb "subject_codes"
    t.string "funding_type"
    t.string "age_range"
    t.jsonb "qualifications"
    t.string "program_type"
    t.boolean "withdrawn"
    t.index ["code"], name: "index_courses_on_code"
    t.index ["exposed_in_find", "open_on_apply"], name: "index_courses_on_exposed_in_find_and_open_on_apply"
    t.index ["provider_id"], name: "index_courses_on_provider_id"
    t.index ["recruitment_cycle_year", "provider_id", "code"], name: "index_courses_on_cycle_provider_and_code", unique: true
  end

  create_table "emails", force: :cascade do |t|
    t.string "to", null: false
    t.string "subject", null: false
    t.string "mailer", null: false
    t.string "mail_template", null: false
    t.text "body", null: false
    t.string "notify_reference"
    t.bigint "application_form_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "delivery_status", default: "unknown", null: false
    t.index ["application_form_id"], name: "index_emails_on_application_form_id"
  end

  create_table "english_proficiencies", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.string "efl_qualification_type"
    t.bigint "efl_qualification_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "qualification_status", null: false
    t.text "no_qualification_details"
    t.index ["application_form_id"], name: "index_english_proficiencies_on_application_form_id", unique: true
    t.index ["efl_qualification_type", "efl_qualification_id"], name: "index_elp_on_efl_qualification_type_and_id"
  end

  create_table "features", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_features_on_name", unique: true
  end

  create_table "ielts_qualifications", force: :cascade do |t|
    t.string "trf_number", null: false
    t.string "band_score", null: false
    t.integer "award_year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notes", force: :cascade do |t|
    t.string "subject"
    t.text "message"
    t.bigint "application_choice_id", null: false
    t.bigint "provider_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_choice_id"], name: "index_notes_on_application_choice_id"
    t.index ["provider_user_id"], name: "index_notes_on_provider_user_id"
  end

  create_table "other_efl_qualifications", force: :cascade do |t|
    t.string "name", null: false
    t.string "grade", null: false
    t.integer "award_year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "provider_relationship_permissions", force: :cascade do |t|
    t.integer "training_provider_id", null: false
    t.integer "ratifying_provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "setup_at"
    t.boolean "training_provider_can_make_decisions", default: false, null: false
    t.boolean "training_provider_can_view_safeguarding_information", default: false, null: false
    t.boolean "ratifying_provider_can_make_decisions", default: false, null: false
    t.boolean "ratifying_provider_can_view_safeguarding_information", default: false, null: false
    t.index ["training_provider_id", "ratifying_provider_id"], name: "index_relationships_on_training_and_ratifying_provider_ids", unique: true
  end

  create_table "provider_users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "dfe_sign_in_uid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_signed_in_at"
    t.string "first_name"
    t.string "last_name"
    t.string "magic_link_token"
    t.datetime "magic_link_token_sent_at"
    t.index ["dfe_sign_in_uid"], name: "index_provider_users_on_dfe_sign_in_uid", unique: true
    t.index ["email_address"], name: "index_provider_users_on_email_address", unique: true
  end

  create_table "provider_users_providers", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "provider_user_id", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.boolean "manage_users", default: false, null: false
    t.boolean "view_safeguarding_information", default: false, null: false
    t.boolean "make_decisions", default: false, null: false
    t.boolean "manage_organisations", default: false, null: false
    t.index ["provider_id", "provider_user_id"], name: "index_provider_users_providers_by_provider_and_provider_user", unique: true
    t.index ["provider_id"], name: "index_provider_users_providers_on_provider_id"
    t.index ["provider_user_id"], name: "index_provider_users_providers_on_provider_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "sync_courses", default: false, null: false
    t.string "region_code"
    t.index ["code"], name: "index_providers_on_code", unique: true
  end

  create_table "reference_tokens", force: :cascade do |t|
    t.bigint "application_reference_id", null: false
    t.string "hashed_token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_reference_id"], name: "index_reference_tokens_on_application_reference_id"
    t.index ["hashed_token"], name: "index_reference_tokens_on_hashed_token", unique: true
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
    t.string "safeguarding_concerns"
    t.string "relationship_correction"
    t.string "referee_type"
    t.string "safeguarding_concerns_status", default: "not_answered_yet", null: false
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
    t.datetime "discarded_at"
    t.index ["dfe_sign_in_uid"], name: "index_support_users_on_dfe_sign_in_uid", unique: true
    t.index ["discarded_at"], name: "index_support_users_on_discarded_at"
    t.index ["email_address"], name: "index_support_users_on_email_address", unique: true
  end

  create_table "toefl_qualifications", force: :cascade do |t|
    t.string "registration_number", null: false
    t.integer "total_score", null: false
    t.integer "award_year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "validation_errors", force: :cascade do |t|
    t.string "form_object", null: false
    t.integer "user_id"
    t.string "user_type"
    t.string "request_path", null: false
    t.jsonb "details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["form_object"], name: "index_validation_errors_on_form_object"
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
  add_foreign_key "application_forms", "application_forms", column: "previous_application_form_id"
  add_foreign_key "application_forms", "candidates", on_delete: :cascade
  add_foreign_key "application_qualifications", "application_forms", on_delete: :cascade
  add_foreign_key "application_work_history_breaks", "application_forms", on_delete: :cascade
  add_foreign_key "course_options", "courses", on_delete: :cascade
  add_foreign_key "course_options", "sites", on_delete: :cascade
  add_foreign_key "courses", "providers"
  add_foreign_key "emails", "application_forms", on_delete: :cascade
  add_foreign_key "notes", "application_choices", on_delete: :cascade
  add_foreign_key "notes", "provider_users", on_delete: :cascade
  add_foreign_key "provider_agreements", "provider_users"
  add_foreign_key "provider_agreements", "providers"
  add_foreign_key "provider_relationship_permissions", "providers", column: "ratifying_provider_id"
  add_foreign_key "provider_relationship_permissions", "providers", column: "training_provider_id"
  add_foreign_key "reference_tokens", "\"references\"", column: "application_reference_id", on_delete: :cascade
  add_foreign_key "references", "application_forms", on_delete: :cascade
  add_foreign_key "sites", "providers"
  add_foreign_key "vendor_api_tokens", "providers", on_delete: :cascade
end

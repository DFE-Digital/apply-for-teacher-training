# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_30_153248) do
  create_sequence "qualifications_public_id_seq", start: 120000

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "handle_interviews", ["in_manage", "outside_service"]

  create_table "account_recovery_request_codes", force: :cascade do |t|
    t.bigint "account_recovery_request_id", null: false
    t.string "code_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_recovery_request_id"], name: "idx_on_account_recovery_request_id_c1c0af72cc"
  end

  create_table "account_recovery_requests", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.datetime "created_at", null: false
    t.string "previous_account_email_address"
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_account_recovery_requests_on_candidate_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "adviser_sign_up_requests", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.datetime "created_at", null: false
    t.datetime "sent_to_adviser_at"
    t.bigint "teaching_subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_adviser_sign_up_requests_on_application_form_id"
    t.index ["teaching_subject_id"], name: "index_adviser_sign_up_requests_on_teaching_subject_id"
  end

  create_table "adviser_teaching_subjects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "external_identifier", null: false
    t.string "level", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_adviser_teaching_subjects_on_discarded_at"
    t.index ["external_identifier"], name: "index_adviser_teaching_subjects_on_external_identifier", unique: true
  end

  create_table "application_choices", force: :cascade do |t|
    t.datetime "accepted_at", precision: nil
    t.bigint "application_form_id", null: false
    t.datetime "conditions_not_met_at", precision: nil
    t.datetime "course_changed_at"
    t.bigint "course_option_id", null: false
    t.datetime "created_at", null: false
    t.bigint "current_course_option_id"
    t.integer "current_recruitment_cycle_year"
    t.datetime "decline_by_default_at", precision: nil
    t.integer "decline_by_default_days"
    t.datetime "declined_at", precision: nil
    t.boolean "declined_by_default", default: false, null: false
    t.datetime "inactive_at"
    t.datetime "offer_changed_at", precision: nil
    t.datetime "offer_deferred_at", precision: nil
    t.string "offer_withdrawal_reason"
    t.datetime "offer_withdrawn_at", precision: nil
    t.datetime "offered_at", precision: nil
    t.bigint "original_course_option_id"
    t.text "personal_statement"
    t.bigint "provider_ids", default: [], array: true
    t.datetime "recruited_at", precision: nil
    t.datetime "reject_by_default_at", precision: nil
    t.integer "reject_by_default_days"
    t.datetime "reject_by_default_feedback_sent_at", precision: nil
    t.datetime "rejected_at", precision: nil
    t.boolean "rejected_by_default", default: false, null: false
    t.string "rejection_reason"
    t.string "rejection_reasons_type"
    t.boolean "school_placement_auto_selected", default: false, null: false
    t.datetime "sent_to_provider_at", precision: nil
    t.string "status", null: false
    t.string "status_before_deferral"
    t.jsonb "structured_rejection_reasons"
    t.text "structured_withdrawal_reasons", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "visa_explanation"
    t.string "visa_explanation_details"
    t.jsonb "withdrawal_feedback"
    t.datetime "withdrawn_at", precision: nil
    t.boolean "withdrawn_or_declined_for_candidate_by_provider"
    t.index ["application_form_id"], name: "index_application_choices_on_application_form_id"
    t.index ["course_option_id"], name: "index_application_choices_on_course_option_id"
    t.index ["current_recruitment_cycle_year"], name: "index_application_choices_on_current_recruitment_cycle_year"
    t.index ["provider_ids"], name: "index_application_choices_on_provider_ids", using: :gin
  end

  create_table "application_experiences", force: :cascade do |t|
    t.string "commitment"
    t.datetime "created_at", null: false
    t.boolean "currently_working"
    t.text "details"
    t.datetime "end_date", precision: nil
    t.boolean "end_date_unknown"
    t.bigint "experienceable_id", null: false
    t.string "experienceable_type", null: false
    t.string "organisation", null: false
    t.boolean "relevant_skills"
    t.string "role", null: false
    t.datetime "start_date", precision: nil, null: false
    t.boolean "start_date_unknown"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.string "working_pattern"
    t.boolean "working_with_children"
    t.index ["experienceable_type", "experienceable_id"], name: "index_application_experiences_on_experienceable"
  end

  create_table "application_feedback", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.boolean "consent_to_be_contacted", default: false, null: false
    t.datetime "created_at", null: false
    t.string "feedback"
    t.string "page_title", null: false
    t.string "path", null: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_application_feedback_on_application_form_id"
  end

  create_table "application_forms", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line2"
    t.string "address_line3"
    t.string "address_line4"
    t.string "address_type"
    t.boolean "adviser_interruption_response"
    t.string "adviser_status", default: "unassigned", null: false
    t.text "becoming_a_teacher"
    t.boolean "becoming_a_teacher_completed"
    t.datetime "becoming_a_teacher_completed_at", precision: nil
    t.bigint "candidate_id", null: false
    t.boolean "contact_details_completed"
    t.datetime "contact_details_completed_at", precision: nil
    t.string "country"
    t.datetime "country_residency_date_from"
    t.boolean "country_residency_since_birth"
    t.boolean "course_choices_completed"
    t.datetime "course_choices_completed_at", precision: nil
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.boolean "degrees_completed"
    t.datetime "degrees_completed_at", precision: nil
    t.string "disability_disclosure"
    t.boolean "disclose_disability"
    t.datetime "edit_by", precision: nil
    t.jsonb "editable_sections"
    t.datetime "editable_until"
    t.boolean "efl_completed"
    t.datetime "efl_completed_at", precision: nil
    t.boolean "english_gcse_completed"
    t.datetime "english_gcse_completed_at", precision: nil
    t.text "english_language_details"
    t.boolean "english_main_language"
    t.jsonb "equality_and_diversity"
    t.boolean "equality_and_diversity_completed"
    t.datetime "equality_and_diversity_completed_at", precision: nil
    t.boolean "feedback_form_complete", default: false
    t.string "feedback_satisfaction_level"
    t.text "feedback_suggestions"
    t.string "fifth_nationality"
    t.string "first_name"
    t.string "first_nationality"
    t.string "fourth_nationality"
    t.text "further_information"
    t.string "immigration_status"
    t.string "international_address"
    t.text "interview_preferences"
    t.boolean "interview_preferences_completed"
    t.datetime "interview_preferences_completed_at", precision: nil
    t.string "last_name"
    t.float "latitude"
    t.float "longitude"
    t.boolean "maths_gcse_completed"
    t.datetime "maths_gcse_completed_at", precision: nil
    t.boolean "no_other_qualifications", default: false
    t.text "other_language_details"
    t.boolean "other_qualifications_completed"
    t.datetime "other_qualifications_completed_at", precision: nil
    t.boolean "personal_details_completed"
    t.datetime "personal_details_completed_at", precision: nil
    t.string "phase", default: "apply_1", null: false
    t.string "phone_number"
    t.string "postcode"
    t.integer "previous_application_form_id"
    t.boolean "previous_teacher_training_completed"
    t.datetime "previous_teacher_training_completed_at", precision: nil
    t.integer "recruitment_cycle_year", null: false
    t.boolean "references_completed"
    t.datetime "references_completed_at", precision: nil
    t.string "region_code"
    t.string "right_to_work_or_study"
    t.string "right_to_work_or_study_details"
    t.text "safeguarding_issues"
    t.boolean "safeguarding_issues_completed"
    t.datetime "safeguarding_issues_completed_at", precision: nil
    t.string "safeguarding_issues_status", default: "not_answered_yet", null: false
    t.boolean "science_gcse_completed"
    t.datetime "science_gcse_completed_at", precision: nil
    t.string "second_nationality"
    t.text "subject_knowledge"
    t.boolean "subject_knowledge_completed"
    t.datetime "subject_knowledge_completed_at", precision: nil
    t.datetime "submitted_at", precision: nil
    t.string "support_reference", limit: 10
    t.string "third_nationality"
    t.boolean "training_with_a_disability_completed"
    t.datetime "training_with_a_disability_completed_at", precision: nil
    t.boolean "university_degree"
    t.datetime "updated_at", null: false
    t.datetime "visa_expired_at"
    t.boolean "volunteering_completed"
    t.datetime "volunteering_completed_at", precision: nil
    t.boolean "volunteering_experience"
    t.text "work_history_breaks"
    t.boolean "work_history_completed"
    t.datetime "work_history_completed_at", precision: nil
    t.text "work_history_explanation"
    t.string "work_history_status"
    t.index ["candidate_id"], name: "index_application_forms_on_candidate_id"
    t.index ["recruitment_cycle_year"], name: "index_application_forms_on_recruitment_cycle_year"
    t.index ["submitted_at"], name: "index_application_forms_on_submitted_at"
    t.index ["updated_at"], name: "index_application_forms_on_updated_at", order: :desc
  end

  create_table "application_qualifications", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.string "award_year"
    t.string "comparable_uk_degree"
    t.string "comparable_uk_qualification"
    t.jsonb "constituent_grades"
    t.datetime "created_at", null: false
    t.boolean "currently_completing_qualification"
    t.uuid "degree_grade_uuid"
    t.uuid "degree_institution_uuid"
    t.uuid "degree_subject_uuid"
    t.uuid "degree_type_uuid"
    t.string "enic_reason"
    t.string "enic_reference"
    t.string "grade"
    t.string "grade_hesa_code"
    t.string "institution_country"
    t.string "institution_hesa_code"
    t.string "institution_name"
    t.boolean "international", default: false, null: false
    t.string "level", null: false
    t.text "missing_explanation"
    t.string "non_uk_qualification_type"
    t.text "not_completed_explanation"
    t.string "other_uk_qualification_type", limit: 100
    t.boolean "predicted_grade"
    t.bigint "public_id"
    t.string "qualification_level"
    t.uuid "qualification_level_uuid"
    t.string "qualification_type"
    t.string "qualification_type_hesa_code"
    t.string "start_year"
    t.string "subject"
    t.string "subject_hesa_code"
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_application_qualifications_on_application_form_id"
    t.index ["grade_hesa_code"], name: "qualifications_by_grade_hesa_code"
    t.index ["institution_hesa_code"], name: "qualifications_by_institution_hesa_code"
    t.index ["qualification_type_hesa_code"], name: "qualifications_by_type_hesa_code"
    t.index ["subject_hesa_code"], name: "qualifications_by_subject_hesa_code"
  end

  create_table "application_work_history_breaks", force: :cascade do |t|
    t.bigint "breakable_id", null: false
    t.string "breakable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "end_date", precision: nil, null: false
    t.text "reason", null: false
    t.datetime "start_date", precision: nil, null: false
    t.datetime "updated_at", null: false
    t.index ["breakable_type", "breakable_id"], name: "index_application_work_history_breaks_on_breakable"
  end

  create_table "audits", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.jsonb "audited_changes"
    t.string "comment"
    t.datetime "created_at", precision: nil
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "action"], name: "index_audits_on_auditable_type_and_auditable_id_and_action"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["auditable_type", "id"], name: "index_audits_on_auditable_type_and_id"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authentication_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hashed_token", null: false
    t.string "path"
    t.datetime "updated_at", null: false
    t.datetime "used_at", precision: nil
    t.bigint "user_id", null: false
    t.string "user_type", null: false
    t.index ["hashed_token"], name: "index_authentication_tokens_on_hashed_token", unique: true
    t.index ["user_id", "user_type"], name: "index_authentication_tokens_on_id_and_type"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "data_source"
    t.bigint "query_id"
    t.text "statement"
    t.bigint "user_id"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.text "emails"
    t.datetime "last_run_at", precision: nil
    t.text "message"
    t.bigint "query_id"
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dashboard_id"
    t.integer "position"
    t.bigint "query_id"
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "candidate_location_preferences", force: :cascade do |t|
    t.bigint "candidate_preference_id", null: false
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 12, scale: 8
    t.decimal "longitude", precision: 12, scale: 8
    t.string "name", null: false
    t.bigint "provider_id"
    t.datetime "updated_at", null: false
    t.float "within", null: false
    t.index ["candidate_preference_id"], name: "idx_on_candidate_preference_id_f06d90defb"
    t.index ["latitude"], name: "index_candidate_location_preferences_on_latitude"
    t.index ["longitude"], name: "index_candidate_location_preferences_on_longitude"
    t.index ["provider_id"], name: "index_candidate_location_preferences_on_provider_id"
  end

  create_table "candidate_pool_applications", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.bigint "candidate_id", null: false
    t.boolean "course_funding_type_fee"
    t.boolean "course_type_postgraduate", default: false, null: false
    t.boolean "course_type_undergraduate", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "needs_visa", default: false, null: false
    t.bigint "rejected_provider_ids", default: [], null: false, array: true
    t.boolean "study_mode_full_time", default: false, null: false
    t.boolean "study_mode_part_time", default: false, null: false
    t.bigint "subject_ids", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_candidate_pool_applications_on_application_form_id", unique: true
    t.index ["candidate_id"], name: "index_candidate_pool_applications_on_candidate_id"
  end

  create_table "candidate_preferences", force: :cascade do |t|
    t.bigint "application_form_id"
    t.datetime "created_at", null: false
    t.boolean "dynamic_location_preferences"
    t.string "funding_type"
    t.text "opt_out_reason"
    t.string "pool_status"
    t.string "status", default: "draft", null: false
    t.string "training_locations"
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_candidate_preferences_on_application_form_id"
  end

  create_table "candidates", force: :cascade do |t|
    t.boolean "account_locked", default: false, null: false
    t.string "account_recovery_status", default: "not_started", null: false
    t.datetime "candidate_api_updated_at", precision: nil
    t.integer "course_from_find_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "email_address", null: false
    t.bigint "fraud_match_id"
    t.boolean "hide_in_reporting", default: false, null: false
    t.datetime "last_signed_in_at", precision: nil
    t.string "magic_link_token"
    t.datetime "magic_link_token_sent_at", precision: nil
    t.boolean "sign_up_email_bounced", default: false, null: false
    t.boolean "submission_blocked", default: false, null: false
    t.boolean "unsubscribed_from_emails", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_locked"], name: "index_candidates_on_account_locked"
    t.index ["email_address"], name: "index_candidates_on_email_address", unique: true
    t.index ["fraud_match_id"], name: "index_candidates_on_fraud_match_id"
    t.index ["magic_link_token"], name: "index_candidates_on_magic_link_token", unique: true
    t.index ["submission_blocked"], name: "index_candidates_on_submission_blocked"
    t.index ["unsubscribed_from_emails"], name: "index_candidates_on_unsubscribed_from_emails"
  end

  create_table "chasers_sent", force: :cascade do |t|
    t.bigint "chased_id", null: false
    t.string "chased_type", null: false
    t.string "chaser_type", null: false
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chased_type", "chased_id"], name: "index_chasers_sent_on_chased_type_and_chased_id"
    t.index ["course_id"], name: "index_chasers_sent_on_course_id"
  end

  create_table "course_options", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.bigint "site_id", null: false
    t.boolean "site_still_valid", default: true, null: false
    t.string "study_mode", default: "full_time", null: false
    t.datetime "updated_at", null: false
    t.string "vacancy_status", null: false
    t.index ["course_id"], name: "index_course_options_on_course_id"
    t.index ["site_id", "course_id", "study_mode"], name: "index_course_options_on_site_id_and_course_id_and_study_mode", unique: true
    t.index ["site_id"], name: "index_course_options_on_site_id"
    t.index ["vacancy_status", "site_still_valid"], name: "index_course_options_on_vacancy_status_and_site_still_valid"
  end

  create_table "course_subjects", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "subject_id"], name: "index_course_subjects_on_course_id_and_subject_id", unique: true
    t.index ["course_id"], name: "index_course_subjects_on_course_id"
    t.index ["subject_id"], name: "index_course_subjects_on_subject_id"
  end

  create_table "courses", force: :cascade do |t|
    t.boolean "accept_english_gcse_equivalency"
    t.boolean "accept_gcse_equivalency"
    t.boolean "accept_maths_gcse_equivalency"
    t.boolean "accept_pending_gcse"
    t.boolean "accept_science_gcse_equivalency"
    t.integer "accredited_provider_id"
    t.string "additional_gcse_equivalencies"
    t.string "age_range"
    t.integer "application_status", default: 0, null: false
    t.datetime "applications_open_from", precision: nil
    t.boolean "can_sponsor_skilled_worker_visa"
    t.boolean "can_sponsor_student_visa"
    t.string "code"
    t.string "course_length"
    t.datetime "created_at", null: false
    t.string "degree_grade"
    t.string "degree_subject_requirements"
    t.string "description"
    t.boolean "exposed_in_find"
    t.string "fee_details"
    t.integer "fee_domestic"
    t.integer "fee_international"
    t.string "financial_support"
    t.string "funding_type"
    t.string "level"
    t.string "name"
    t.string "program_type"
    t.bigint "provider_id", null: false
    t.jsonb "qualifications"
    t.integer "recruitment_cycle_year", null: false
    t.string "salary_details"
    t.datetime "start_date", precision: nil
    t.string "study_mode", limit: 1, default: "F", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.datetime "visa_sponsorship_application_deadline_at"
    t.boolean "withdrawn"
    t.index ["applications_open_from"], name: "index_courses_on_applications_open_from"
    t.index ["code"], name: "index_courses_on_code"
    t.index ["provider_id"], name: "index_courses_on_provider_id"
    t.index ["recruitment_cycle_year", "provider_id", "code"], name: "index_courses_on_cycle_provider_and_code", unique: true
  end

  create_table "data_exports", force: :cascade do |t|
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.string "export_type"
    t.bigint "initiator_id"
    t.string "initiator_type"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["initiator_type", "initiator_id"], name: "index_data_exports_on_initiator_type_and_initiator_id"
  end

  create_table "data_migrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "service_name"
    t.string "timestamp"
    t.datetime "updated_at", null: false
    t.index ["service_name", "timestamp"], name: "index_data_migrations_on_service_name_and_timestamp", unique: true
  end

  create_table "deferred_offer_confirmations", force: :cascade do |t|
    t.string "conditions_status"
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.bigint "offer_id", null: false
    t.bigint "offered_course_option_id"
    t.bigint "provider_user_id", null: false
    t.bigint "site_id"
    t.string "study_mode"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_deferred_offer_confirmations_on_course_id"
    t.index ["offer_id"], name: "index_deferred_offer_confirmations_on_offer_id"
    t.index ["offered_course_option_id"], name: "index_deferred_offer_confirmations_on_offered_course_option_id"
    t.index ["provider_user_id"], name: "index_deferred_offer_confirmations_on_provider_user_id"
    t.index ["site_id"], name: "index_deferred_offer_confirmations_on_site_id"
  end

  create_table "dsi_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dfe_sign_in_uid"
    t.string "email_address"
    t.string "first_name"
    t.string "id_token"
    t.bigint "impersonated_provider_user_id"
    t.string "ip_address"
    t.datetime "last_active_at"
    t.string "last_name"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.string "user_type", null: false
    t.index ["impersonated_provider_user_id"], name: "index_dsi_sessions_on_impersonated_provider_user_id"
    t.index ["user_type", "user_id"], name: "index_dsi_sessions_on_user"
    t.check_constraint "NOT (user_type::text = 'ProviderUser'::text AND impersonated_provider_user_id IS NOT NULL)", name: "provider_not_impersonating_provider"
  end

  create_table "email_clicks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "email_id", null: false
    t.string "path", null: false
    t.datetime "updated_at", null: false
    t.index ["email_id"], name: "index_email_clicks_on_email_id"
  end

  create_table "emails", force: :cascade do |t|
    t.bigint "application_form_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "delivery_status", default: "unknown", null: false
    t.string "mail_template", null: false
    t.string "mailer", null: false
    t.string "notify_reference"
    t.string "subject", null: false
    t.string "to", null: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_emails_on_application_form_id"
    t.index ["created_at"], name: "index_emails_on_created_at"
    t.index ["notify_reference"], name: "index_emails_on_notify_reference"
  end

  create_table "english_proficiencies", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.datetime "created_at", null: false
    t.boolean "degree_taught_in_english", default: false, null: false
    t.boolean "draft", default: true, null: false
    t.bigint "efl_qualification_id"
    t.string "efl_qualification_type"
    t.boolean "has_qualification", default: false, null: false
    t.boolean "no_qualification", default: false, null: false
    t.text "no_qualification_details"
    t.boolean "qualification_not_needed", default: false, null: false
    t.string "qualification_status"
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_english_proficiencies_on_application_form_id"
    t.index ["degree_taught_in_english"], name: "index_english_proficiencies_on_degree_taught_in_english"
    t.index ["draft"], name: "index_english_proficiencies_on_draft"
    t.index ["efl_qualification_type", "efl_qualification_id"], name: "index_elp_on_efl_qualification_type_and_id"
    t.index ["has_qualification"], name: "index_english_proficiencies_on_has_qualification"
    t.index ["no_qualification"], name: "index_english_proficiencies_on_no_qualification"
    t.index ["qualification_not_needed"], name: "index_english_proficiencies_on_qualification_not_needed"
  end

  create_table "features", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_features_on_name", unique: true
  end

  create_table "field_test_events", force: :cascade do |t|
    t.datetime "created_at"
    t.bigint "field_test_membership_id"
    t.string "name"
    t.index ["field_test_membership_id"], name: "index_field_test_events_on_field_test_membership_id"
  end

  create_table "field_test_memberships", force: :cascade do |t|
    t.boolean "converted", default: false
    t.datetime "created_at"
    t.string "experiment"
    t.string "participant_id"
    t.string "participant_type"
    t.string "variant"
    t.index ["experiment", "created_at"], name: "index_field_test_memberships_on_experiment_and_created_at"
    t.index ["participant_type", "participant_id", "experiment"], name: "index_field_test_memberships_on_participant", unique: true
  end

  create_table "find_feedback", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address"
    t.string "feedback", null: false
    t.string "find_controller", null: false
    t.string "path", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fraud_matches", force: :cascade do |t|
    t.boolean "blocked", default: false
    t.datetime "candidate_last_contacted_at", precision: nil
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "last_name"
    t.string "postcode"
    t.integer "recruitment_cycle_year"
    t.boolean "resolved", default: false, null: false
    t.datetime "updated_at", null: false
  end

  create_table "ielts_qualifications", force: :cascade do |t|
    t.integer "award_year", null: false
    t.string "band_score", null: false
    t.datetime "created_at", null: false
    t.string "trf_number", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interviews", force: :cascade do |t|
    t.text "additional_details"
    t.bigint "application_choice_id", null: false
    t.text "cancellation_reason"
    t.datetime "cancelled_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "date_and_time", precision: nil
    t.text "location"
    t.bigint "provider_id", null: false
    t.datetime "updated_at", null: false
    t.index ["application_choice_id"], name: "index_interviews_on_application_choice_id"
    t.index ["provider_id"], name: "index_interviews_on_provider_id"
  end

  create_table "monthly_statistics_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "generation_date"
    t.string "month"
    t.date "publication_date"
    t.json "statistics"
    t.datetime "updated_at", null: false
  end

  create_table "national_recruitment_performance_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle_week", null: false
    t.date "generation_date"
    t.date "publication_date", null: false
    t.integer "recruitment_cycle_year"
    t.json "statistics"
    t.datetime "updated_at", null: false
    t.index ["recruitment_cycle_year"], name: "idx_on_recruitment_cycle_year_11d37af39b"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "application_choice_id", null: false
    t.datetime "created_at", null: false
    t.text "message"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "user_type"
    t.index ["application_choice_id"], name: "index_notes_on_application_choice_id"
    t.index ["user_id", "user_type"], name: "index_notes_on_user_id_and_user_type"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "notification_type", null: false
    t.bigint "notified_id", null: false
    t.string "notified_type", null: false
    t.datetime "updated_at", null: false
    t.index ["notified_type", "notified_id"], name: "index_notifications_on_notified"
  end

  create_table "notify_send_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_addresses", array: true
    t.bigint "support_user_id", null: false
    t.string "template_id", null: false
    t.datetime "updated_at", null: false
    t.index ["support_user_id"], name: "index_notify_send_requests_on_support_user_id"
  end

  create_table "offer_conditions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "details"
    t.bigint "offer_id", null: false
    t.string "status", default: "pending", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id"], name: "index_offer_conditions_on_offer_id"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "application_choice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_choice_id"], name: "index_offers_on_application_choice_id"
  end

  create_table "one_login_auths", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_one_login_auths_on_candidate_id"
  end

  create_table "other_efl_qualifications", force: :cascade do |t|
    t.integer "award_year", null: false
    t.datetime "created_at", null: false
    t.string "grade", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pool_eligible_application_forms", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_pool_eligible_application_forms_on_application_form_id"
  end

  create_table "pool_invite_decline_reasons", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "invite_id", null: false
    t.string "reason"
    t.datetime "updated_at", null: false
    t.index ["invite_id"], name: "index_pool_invite_decline_reasons_on_invite_id"
    t.index ["reason"], name: "index_pool_invite_decline_reasons_on_reason"
  end

  create_table "pool_invites", force: :cascade do |t|
    t.bigint "application_choice_id"
    t.bigint "application_form_id"
    t.string "candidate_decision", default: "not_responded"
    t.bigint "candidate_id", null: false
    t.bigint "course_id", null: false
    t.boolean "course_open", default: true
    t.datetime "created_at", null: false
    t.bigint "invited_by_id", null: false
    t.text "message_content"
    t.bigint "provider_id", null: false
    t.boolean "provider_message"
    t.integer "recruitment_cycle_year"
    t.datetime "sent_to_candidate_at"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["application_choice_id"], name: "index_pool_invites_on_application_choice_id"
    t.index ["application_form_id"], name: "index_pool_invites_on_application_form_id"
    t.index ["candidate_id"], name: "index_pool_invites_on_candidate_id"
    t.index ["course_id"], name: "index_pool_invites_on_course_id"
    t.index ["invited_by_id"], name: "index_pool_invites_on_invited_by_id"
    t.index ["provider_id"], name: "index_pool_invites_on_provider_id"
    t.index ["recruitment_cycle_year"], name: "index_pool_invites_on_recruitment_cycle_year"
  end

  create_table "possible_previous_teacher_trainings", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.datetime "created_at", null: false
    t.date "ended_on", null: false
    t.bigint "provider_id"
    t.string "provider_name", null: false
    t.date "started_on", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_possible_previous_teacher_trainings_on_candidate_id"
    t.index ["provider_id"], name: "index_possible_previous_teacher_trainings_on_provider_id"
  end

  create_table "previous_teacher_trainings", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.datetime "created_at", null: false
    t.text "details"
    t.bigint "duplicate_previous_teacher_training_id"
    t.datetime "ended_at"
    t.bigint "provider_id"
    t.string "provider_name"
    t.string "started"
    t.datetime "started_at"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_previous_teacher_trainings_on_application_form_id"
    t.index ["duplicate_previous_teacher_training_id"], name: "idx_on_duplicate_previous_teacher_training_id_3aef87bfcc"
    t.index ["provider_id"], name: "index_previous_teacher_trainings_on_provider_id"
  end

  create_table "provider_agreements", force: :cascade do |t|
    t.datetime "accepted_at", precision: nil
    t.string "agreement_type"
    t.datetime "created_at", null: false
    t.bigint "provider_id", null: false
    t.bigint "provider_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_agreements_on_provider_id"
    t.index ["provider_user_id"], name: "index_provider_agreements_on_provider_user_id"
  end

  create_table "provider_edi_reports", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.integer "cycle_week", null: false
    t.date "generation_date"
    t.bigint "provider_id"
    t.date "publication_date", null: false
    t.integer "recruitment_cycle_year", null: false
    t.json "statistics"
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_edi_reports_on_provider_id"
    t.index ["recruitment_cycle_year"], name: "index_provider_edi_reports_on_recruitment_cycle_year"
  end

  create_table "provider_pool_actions", force: :cascade do |t|
    t.bigint "actioned_by_id", null: false
    t.bigint "application_form_id", null: false
    t.datetime "created_at", null: false
    t.integer "recruitment_cycle_year"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["actioned_by_id"], name: "index_provider_pool_actions_on_actioned_by_id"
    t.index ["application_form_id"], name: "index_provider_pool_actions_on_application_form_id"
    t.index ["status", "recruitment_cycle_year", "actioned_by_id"], name: "idx_on_status_recruitment_cycle_year_actioned_by_id_3a3a559a16"
  end

  create_table "provider_recruitment_performance_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle_week", null: false
    t.date "generation_date"
    t.bigint "provider_id", null: false
    t.date "publication_date", null: false
    t.integer "recruitment_cycle_year"
    t.json "statistics"
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_recruitment_performance_reports_on_provider_id"
    t.index ["recruitment_cycle_year"], name: "idx_on_recruitment_cycle_year_2c77f78ddd"
  end

  create_table "provider_relationship_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "ratifying_provider_can_make_decisions", default: false, null: false
    t.boolean "ratifying_provider_can_view_diversity_information", default: false, null: false
    t.boolean "ratifying_provider_can_view_safeguarding_information", default: false, null: false
    t.integer "ratifying_provider_id", null: false
    t.datetime "setup_at", precision: nil
    t.boolean "training_provider_can_make_decisions", default: false, null: false
    t.boolean "training_provider_can_view_diversity_information", default: false, null: false
    t.boolean "training_provider_can_view_safeguarding_information", default: false, null: false
    t.integer "training_provider_id", null: false
    t.datetime "updated_at", null: false
    t.index ["training_provider_id", "ratifying_provider_id"], name: "index_relationships_on_training_and_ratifying_provider_ids", unique: true
  end

  create_table "provider_user_filters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "filters", default: {}
    t.string "kind", null: false
    t.integer "pagination_page"
    t.bigint "provider_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_provider_user_filters_on_kind"
    t.index ["provider_user_id"], name: "index_provider_user_filters_on_provider_user_id"
  end

  create_table "provider_user_notifications", force: :cascade do |t|
    t.boolean "application_received", default: true, null: false
    t.boolean "application_rejected_by_default", default: true, null: false
    t.boolean "application_withdrawn", default: true, null: false
    t.boolean "chase_provider_decision", default: true, null: false
    t.datetime "created_at", null: false
    t.boolean "marketing_emails", default: true, null: false
    t.boolean "offer_accepted", default: true, null: false
    t.boolean "offer_declined", default: true, null: false
    t.bigint "provider_user_id", null: false
    t.boolean "reference_received", default: true
    t.datetime "updated_at", null: false
    t.index ["provider_user_id"], name: "index_provider_user_notifications_on_provider_user_id"
  end

  create_table "provider_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dfe_sign_in_uid"
    t.string "email_address", null: false
    t.jsonb "find_a_candidate_filters", default: {}
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_signed_in_at", precision: nil
    t.datetime "updated_at", null: false
    t.index ["dfe_sign_in_uid"], name: "index_provider_users_on_dfe_sign_in_uid", unique: true
    t.index ["email_address"], name: "index_provider_users_on_email_address", unique: true
  end

  create_table "provider_users_providers", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.boolean "make_decisions", default: false, null: false
    t.boolean "manage_api_tokens", default: false, null: false
    t.boolean "manage_organisations", default: false, null: false
    t.boolean "manage_users", default: false, null: false
    t.bigint "provider_id", null: false
    t.bigint "provider_user_id", null: false
    t.boolean "set_up_interviews", default: false, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.boolean "view_diversity_information", default: false, null: false
    t.boolean "view_safeguarding_information", default: false, null: false
    t.index ["provider_id", "provider_user_id"], name: "index_provider_users_providers_by_provider_and_provider_user", unique: true
    t.index ["provider_id"], name: "index_provider_users_providers_on_provider_id"
    t.index ["provider_user_id"], name: "index_provider_users_providers_on_provider_user_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "email_address"
    t.enum "handle_interviews", default: "in_manage", null: false, enum_type: "handle_interviews"
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "phone_number"
    t.string "postcode"
    t.string "provider_type"
    t.string "region_code"
    t.boolean "selectable_school", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.index ["code"], name: "index_providers_on_code", unique: true
    t.index ["vendor_id"], name: "index_providers_on_vendor_id"
  end

  create_table "recruitment_cycle_timetables", force: :cascade do |t|
    t.datetime "apply_deadline_at"
    t.datetime "apply_opens_at"
    t.datetime "created_at", null: false
    t.datetime "decline_by_default_at"
    t.datetime "find_closes_at"
    t.datetime "find_opens_at"
    t.integer "recruitment_cycle_year"
    t.datetime "reject_by_default_at"
    t.datetime "updated_at", null: false
    t.index ["recruitment_cycle_year"], name: "index_recruitment_cycle_timetables_on_recruitment_cycle_year", unique: true
  end

  create_table "reference_tokens", force: :cascade do |t|
    t.bigint "application_reference_id", null: false
    t.datetime "created_at", null: false
    t.string "hashed_token", null: false
    t.datetime "updated_at", null: false
    t.index ["application_reference_id"], name: "index_reference_tokens_on_application_reference_id"
    t.index ["hashed_token"], name: "index_reference_tokens_on_hashed_token", unique: true
  end

  create_table "references", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.datetime "cancelled_at", precision: nil
    t.datetime "cancelled_at_end_of_cycle_at", precision: nil
    t.boolean "confidential"
    t.boolean "consent_to_be_contacted"
    t.datetime "created_at", null: false
    t.boolean "duplicate", default: false
    t.string "email_address"
    t.datetime "email_bounced_at", precision: nil
    t.string "feedback"
    t.datetime "feedback_provided_at", precision: nil
    t.datetime "feedback_refused_at", precision: nil
    t.string "feedback_status", default: "not_requested_yet", null: false
    t.string "hashed_sign_in_token"
    t.string "name"
    t.jsonb "questionnaire"
    t.string "referee_type"
    t.boolean "refused"
    t.string "relationship"
    t.string "relationship_correction"
    t.datetime "reminder_sent_at", precision: nil
    t.boolean "replacement", default: false, null: false
    t.datetime "requested_at", precision: nil
    t.string "safeguarding_concerns"
    t.string "safeguarding_concerns_status", default: "not_answered_yet", null: false
    t.boolean "selected", default: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_references_on_application_form_id"
    t.index ["feedback_status"], name: "index_references_on_feedback_status"
  end

  create_table "regional_edi_reports", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.integer "cycle_week", null: false
    t.date "generation_date"
    t.date "publication_date", null: false
    t.integer "recruitment_cycle_year", null: false
    t.string "region", null: false
    t.json "statistics"
    t.datetime "updated_at", null: false
    t.index ["recruitment_cycle_year"], name: "index_regional_edi_reports_on_recruitment_cycle_year"
  end

  create_table "regional_recruitment_performance_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle_week", null: false
    t.date "generation_date"
    t.date "publication_date", null: false
    t.integer "recruitment_cycle_year", null: false
    t.string "region", null: false
    t.json "statistics"
    t.datetime "updated_at", null: false
    t.index ["recruitment_cycle_year"], name: "idx_on_recruitment_cycle_year_10d73daf75"
  end

  create_table "regional_report_filters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "provider_id"
    t.bigint "provider_user_id"
    t.integer "recruitment_cycle_year"
    t.string "region", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_regional_report_filters_on_provider_id"
    t.index ["provider_user_id"], name: "index_regional_report_filters_on_provider_user_id"
  end

  create_table "rejection_feedbacks", force: :cascade do |t|
    t.bigint "application_choice_id", null: false
    t.datetime "created_at", null: false
    t.boolean "helpful", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["application_choice_id"], name: "index_rejection_feedbacks_on_application_choice_id"
  end

  create_table "service_banners", force: :cascade do |t|
    t.string "body"
    t.datetime "created_at", null: false
    t.string "header"
    t.string "interface"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
  end

  create_table "session_errors", force: :cascade do |t|
    t.string "body"
    t.bigint "candidate_id"
    t.datetime "created_at", null: false
    t.string "error_type", default: "internal"
    t.string "id_token_hint"
    t.json "omniauth_hash"
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_session_errors_on_candidate_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.datetime "created_at", null: false
    t.string "id_token_hint"
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["candidate_id"], name: "index_sessions_on_candidate_id"
  end

  create_table "site_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["name"], name: "index_site_settings_on_name", unique: true
  end

  create_table "sites", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line2"
    t.string "address_line3"
    t.string "address_line4"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "name", null: false
    t.string "postcode"
    t.bigint "provider_id", null: false
    t.string "region"
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.boolean "uuid_generated_by_apply", default: false
    t.index ["provider_id"], name: "index_sites_on_provider_id"
    t.index ["uuid", "provider_id"], name: "index_sites_on_uuid_and_provider_id", unique: true
  end

  create_table "solid_cache_dashboard_events", force: :cascade do |t|
    t.integer "byte_size"
    t.datetime "created_at", null: false
    t.float "duration"
    t.string "event_type", null: false
    t.bigint "key_hash", null: false
    t.string "key_string"
    t.index ["created_at"], name: "index_solid_cache_dashboard_events_on_created_at"
    t.index ["event_type"], name: "index_solid_cache_dashboard_events_on_event_type"
    t.index ["key_hash"], name: "index_solid_cache_dashboard_events_on_key_hash"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
  end

  create_table "support_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dfe_sign_in_uid", null: false
    t.datetime "discarded_at", precision: nil
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_signed_in_at", precision: nil
    t.datetime "updated_at", null: false
    t.index ["dfe_sign_in_uid"], name: "index_support_users_on_dfe_sign_in_uid", unique: true
    t.index ["discarded_at"], name: "index_support_users_on_discarded_at"
    t.index ["email_address"], name: "index_support_users_on_email_address", unique: true
  end

  create_table "toefl_qualifications", force: :cascade do |t|
    t.integer "award_year", null: false
    t.datetime "created_at", null: false
    t.string "registration_number", null: false
    t.integer "total_score", null: false
    t.datetime "updated_at", null: false
  end

  create_table "validation_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "details"
    t.string "form_object", null: false
    t.string "request_path", null: false
    t.string "service"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "user_type"
    t.index ["form_object"], name: "index_validation_errors_on_form_object"
  end

  create_table "vendor_api_requests", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.bigint "provider_id"
    t.jsonb "request_body"
    t.jsonb "request_headers"
    t.string "request_method"
    t.string "request_path"
    t.jsonb "response_body"
    t.jsonb "response_headers"
    t.integer "status_code"
    t.index ["provider_id"], name: "index_vendor_api_requests_on_provider_id"
    t.index ["request_path"], name: "index_vendor_api_requests_on_request_path"
    t.index ["status_code"], name: "index_vendor_api_requests_on_status_code"
  end

  create_table "vendor_api_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "hashed_token", null: false
    t.datetime "last_used_at", precision: nil
    t.bigint "provider_id", null: false
    t.datetime "updated_at", null: false
    t.index ["hashed_token"], name: "index_vendor_api_tokens_on_hashed_token", unique: true
    t.index ["provider_id"], name: "index_vendor_api_tokens_on_provider_id"
  end

  create_table "vendor_api_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "full_name", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_api_token_id", null: false
    t.string "vendor_user_id", null: false
    t.index ["full_name", "email_address", "vendor_user_id", "vendor_api_token_id"], name: "index_vendor_api_users_on_name_email_userid_token", unique: true
    t.index ["vendor_api_token_id"], name: "index_vendor_api_users_on_vendor_api_token_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_vendors_on_name", unique: true
  end

  create_table "withdrawal_reasons", force: :cascade do |t|
    t.bigint "application_choice_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "reason"
    t.string "status", default: "draft"
    t.datetime "updated_at", null: false
    t.index ["application_choice_id"], name: "index_withdrawal_reasons_on_application_choice_id"
    t.index ["reason"], name: "index_withdrawal_reasons_on_reason"
  end

  add_foreign_key "account_recovery_request_codes", "account_recovery_requests", on_delete: :cascade
  add_foreign_key "account_recovery_requests", "candidates", on_delete: :cascade
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "adviser_sign_up_requests", "adviser_teaching_subjects", column: "teaching_subject_id"
  add_foreign_key "adviser_sign_up_requests", "application_forms", on_delete: :cascade
  add_foreign_key "application_choices", "application_forms", on_delete: :cascade
  add_foreign_key "application_choices", "course_options"
  add_foreign_key "application_feedback", "application_forms", on_delete: :cascade
  add_foreign_key "application_forms", "application_forms", column: "previous_application_form_id"
  add_foreign_key "application_forms", "candidates", on_delete: :cascade
  add_foreign_key "application_qualifications", "application_forms", on_delete: :cascade
  add_foreign_key "candidate_location_preferences", "candidate_preferences", on_delete: :cascade
  add_foreign_key "candidate_pool_applications", "application_forms", on_delete: :cascade
  add_foreign_key "candidate_pool_applications", "candidates", on_delete: :cascade
  add_foreign_key "candidates", "fraud_matches"
  add_foreign_key "course_options", "courses", on_delete: :cascade
  add_foreign_key "course_options", "sites", on_delete: :cascade
  add_foreign_key "course_subjects", "courses"
  add_foreign_key "course_subjects", "subjects"
  add_foreign_key "courses", "providers"
  add_foreign_key "deferred_offer_confirmations", "course_options", column: "offered_course_option_id"
  add_foreign_key "deferred_offer_confirmations", "courses"
  add_foreign_key "deferred_offer_confirmations", "offers"
  add_foreign_key "deferred_offer_confirmations", "provider_users"
  add_foreign_key "deferred_offer_confirmations", "sites"
  add_foreign_key "email_clicks", "emails", on_delete: :cascade
  add_foreign_key "emails", "application_forms", on_delete: :cascade
  add_foreign_key "interviews", "application_choices", on_delete: :cascade
  add_foreign_key "interviews", "providers", on_delete: :cascade
  add_foreign_key "notes", "application_choices", on_delete: :cascade
  add_foreign_key "offer_conditions", "offers", on_delete: :cascade
  add_foreign_key "offers", "application_choices", on_delete: :cascade
  add_foreign_key "one_login_auths", "candidates", on_delete: :cascade
  add_foreign_key "pool_eligible_application_forms", "application_forms", on_delete: :cascade
  add_foreign_key "pool_invite_decline_reasons", "pool_invites", column: "invite_id", on_delete: :cascade
  add_foreign_key "pool_invites", "candidates", on_delete: :cascade
  add_foreign_key "pool_invites", "courses", on_delete: :cascade
  add_foreign_key "pool_invites", "provider_users", column: "invited_by_id"
  add_foreign_key "pool_invites", "providers", on_delete: :cascade
  add_foreign_key "possible_previous_teacher_trainings", "candidates"
  add_foreign_key "possible_previous_teacher_trainings", "providers"
  add_foreign_key "previous_teacher_trainings", "application_forms", on_delete: :cascade
  add_foreign_key "previous_teacher_trainings", "providers"
  add_foreign_key "provider_agreements", "provider_users"
  add_foreign_key "provider_agreements", "providers"
  add_foreign_key "provider_edi_reports", "providers", on_delete: :cascade
  add_foreign_key "provider_pool_actions", "application_forms", on_delete: :cascade
  add_foreign_key "provider_pool_actions", "provider_users", column: "actioned_by_id", on_delete: :cascade
  add_foreign_key "provider_recruitment_performance_reports", "providers"
  add_foreign_key "provider_relationship_permissions", "providers", column: "ratifying_provider_id"
  add_foreign_key "provider_relationship_permissions", "providers", column: "training_provider_id"
  add_foreign_key "provider_user_filters", "provider_users", on_delete: :cascade
  add_foreign_key "provider_user_notifications", "provider_users", on_delete: :cascade
  add_foreign_key "reference_tokens", "references", column: "application_reference_id", on_delete: :cascade
  add_foreign_key "references", "application_forms", on_delete: :cascade
  add_foreign_key "regional_report_filters", "provider_users", on_delete: :cascade
  add_foreign_key "regional_report_filters", "providers", on_delete: :cascade
  add_foreign_key "rejection_feedbacks", "application_choices", on_delete: :cascade
  add_foreign_key "session_errors", "candidates", on_delete: :cascade
  add_foreign_key "sessions", "candidates", on_delete: :cascade
  add_foreign_key "sites", "providers"
  add_foreign_key "vendor_api_tokens", "providers", on_delete: :cascade
  add_foreign_key "withdrawal_reasons", "application_choices", on_delete: :cascade
end

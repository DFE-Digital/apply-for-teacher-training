class DeleteApplication
  include ImpersonationAuditHelper

  attr_reader :actor, :application_form, :zendesk_url

  APPLICATION_FORM_FIELDS_TO_REDACT = %i[
    first_name
    last_name
    first_nationality
    second_nationality
    english_main_language
    english_language_details
    other_language_details
    date_of_birth
    further_information
    phone_number
    address_line1
    address_line2
    address_line3
    address_line4
    country
    postcode
    disability_disclosure
    uk_residency_status
    work_history_explanation
    becoming_a_teacher
    subject_knowledge
    interview_preferences
    work_history_breaks
    volunteering_experience
    equality_and_diversity
    safeguarding_issues
    international_address
    right_to_work_or_study
    right_to_work_or_study_details
    third_nationality
    fourth_nationality
    fifth_nationality
    feedback_satisfaction_level
    feedback_suggestions
    work_history_status
  ].freeze

  ASSOCIATIONS_TO_DESTROY = %i[
    application_work_experiences
    application_volunteering_experiences
    application_qualifications
    application_references
    application_work_history_breaks
    application_feedback
  ].freeze

  def initialize(actor:, application_form:, zendesk_url:)
    @actor = actor
    @application_form = application_form
    @zendesk_url = zendesk_url
  end

  def call!
    raise 'Application has been sent to providers' \
      unless application_form.application_choices.all?(&:unsubmitted?)

    audit(actor) do
      ActiveRecord::Base.transaction do
        ASSOCIATIONS_TO_DESTROY.each { |assoc| application_form.send(assoc)&.destroy_all }
        APPLICATION_FORM_FIELDS_TO_REDACT.each { |attr| application_form.send("#{attr}=", nil) }
        application_form.save!

        reference = application_form.support_reference
        application_form.candidate.update!(email_address: "deleted-application-#{reference}@example.com")

        application_form.own_and_associated_audits.destroy_all
        add_audit_event_for_deletion!
      end
    end
  end

private

  def add_audit_event_for_deletion!
    comment = "Data deletion request: #{zendesk_url}"

    application_form.reload.audits << Audited::Audit.new(
      action: 'destroy',
      user: actor,
      version: 1,
      audited_changes: {},
      comment: comment,
      created_at: Time.zone.now,
    )
  end
end

class GetActivityLogEvents
  INCLUDES = {
    user: %i[
      provider_user
      support_user
    ],
    auditable: %i[
      application_form
      course_option
      course
      site
      provider
      accredited_provider
      current_course_option
    ],
  }.freeze

  INCLUDE_APPLICATION_FORM_CHANGES_TO = [
    'date_of_birth',
    'first_name',
    'last_name',

    # Contact Information
    'last_name',
    'phone_number',
    'address_line1',
    'address_line2',
    'address_line3',
    'address_line4',
    'country',
    'postcode',

    # Interview Preferences
    'interview_preferences',

    # Disability
    'disability_disclosure',
  ].freeze

  INCLUDE_APPLICATION_CHOICE_CHANGES_TO = %w[
    reject_by_default_feedback_sent_at
    course_changed_at
    offer_changed_at
  ].freeze

  IGNORE_STATUS = %i[interviewing].freeze

  def self.call(application_choices:, since: nil)
    since ||= application_choices.includes(:application_form).minimum('application_forms.created_at')

    application_choices_join_sql = <<~COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE_AND_FILTER.squish
      INNER JOIN (#{application_choices.to_sql}) ac
        ON (
          auditable_type = 'ApplicationChoice'
          AND auditable_id = ac.id
          AND action = 'update'
          AND ( #{application_choice_audits_filter_sql} )
        ) OR (
          associated_type = 'ApplicationChoice'
          AND associated_id = ac.id
          AND NOT auditable_type = 'OfferCondition'
        ) OR (
          auditable_type = 'ApplicationForm'
          AND auditable_id = ac.application_form_id
          AND action = 'update'
          AND ( #{application_form_audits_filter_sql} )
        )
    COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE_AND_FILTER

    Audited::Audit.includes(INCLUDES)
                  .joins(application_choices_join_sql)
                  .where('audits.created_at >= ?', since)
                  .order('audits.created_at DESC')
  end

  def self.application_form_audits_filter_sql
    INCLUDE_APPLICATION_FORM_CHANGES_TO.map do |change|
      "jsonb_exists(audited_changes, '#{change}')"
    end.join(' OR ')
  end

  def self.application_choice_audits_filter_sql
    application_choice_audits_filter = INCLUDE_APPLICATION_CHOICE_CHANGES_TO.map do |change|
      "jsonb_exists(audited_changes, '#{change}')"
    end.join(' OR ')

    filtered_statuses = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - IGNORE_STATUS
    status_transitions_to_include = filtered_statuses.map { |status| "'#{status}'" }.join(', ')

    application_choice_audits_filter += " OR audited_changes::json#>>'{status, 1}' IN (#{status_transitions_to_include})"
    application_choice_audits_filter + ignore_interview_cancelled_application_choice_status_change_sql
  end

  def self.ignore_interview_cancelled_application_choice_status_change_sql
    %( AND NOT audited_changes @> '{"status" : ["interviewing", "awaiting_provider_decision"]}')
  end
end

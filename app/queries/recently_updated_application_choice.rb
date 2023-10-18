# Find audits for updates to editable sections on the application form
class RecentlyUpdatedApplicationChoice
  def call(application_choice:, since: application_choice.created_at)
    Audited::Audit
      .where('audits.created_at >= :since AND audits.action = \'update\'', since: since)
      .where(auditable_type: 'ApplicationForm', auditable_id: application_choice.application_form_id)
      .where(application_form_audits_filter_sql)
      .order('audits.created_at DESC')
  end

  def application_form_audits_filter_sql
    attributes.map do |change|
      "jsonb_exists(audited_changes, '#{change}')"
    end.join(' OR ')
  end

  def attributes
    [
      # Personal Information
      'date_of_birth',
      'first_name',
      'last_name',

      # Contact Information
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

      # Equality and diversity
      'equality_and_diversity',
    ]
  end
end

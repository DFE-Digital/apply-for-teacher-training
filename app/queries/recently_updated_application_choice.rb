# Find audits for updates to editable sections on the application form
class RecentlyUpdatedApplicationChoice
  UPDATED_RECENTLY_DAYS = 40

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    return false if @application_choice.sent_to_provider_at.blank?

    since = [UPDATED_RECENTLY_DAYS.days.ago, @application_choice.sent_to_provider_at].max

    Audited::Audit
      .where('audits.created_at >= ? AND audits.action = \'update\'', since)
      .where(auditable_type: 'ApplicationForm', auditable_id: @application_choice.application_form_id)
      .where(application_form_audits_filter_sql)
      .exists?
  end

private

  def application_form_audits_filter_sql
    attributes.map do |attribute|
      "jsonb_exists(audited_changes, '#{attribute}')"
    end.join(' OR ')
  end

  attr_reader :application_choice

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

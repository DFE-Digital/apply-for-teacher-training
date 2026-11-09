class GetDuplicateMatchesForApplicationForm
  NORMALISED_LAST_NAME = 'TRIM(UPPER(unaccent(application_forms.last_name)))'.freeze
  NORMALISED_POSTCODE = "COALESCE(REPLACE(UPPER(application_forms.postcode), ' ', ''), '')".freeze

  def self.call(application_form)
    new(application_form).call
  end

  def initialize(application_form)
    @application_form = application_form
  end

  def call
    return [] if @application_form.last_name.blank? || @application_form.date_of_birth.blank?

    matching_forms = ApplicationForm
      .where(date_of_birth: @application_form.date_of_birth)
      .where("#{NORMALISED_LAST_NAME} = TRIM(UPPER(unaccent(?)))", @application_form.last_name)
      .where("#{NORMALISED_POSTCODE} = ?", normalised_postcode)

    return [] if matching_forms.distinct.count(:candidate_id) < 2

    matching_forms
      .select('DISTINCT ON (application_forms.candidate_id) application_forms.candidate_id, application_forms.last_name, application_forms.date_of_birth')
      .order('application_forms.candidate_id, application_forms.submitted_at DESC NULLS LAST')
      .map do |form|
        {
          'candidate_id' => form.candidate_id,
          'last_name' => form.last_name,
          'date_of_birth' => form.date_of_birth,
          'postcode' => normalised_postcode,
        }
      end
  end

private

  def normalised_postcode
    @application_form.postcode.to_s.upcase.delete(' ')
  end
end

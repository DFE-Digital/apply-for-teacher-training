module SupportInterface
  class OneTimeDegreeExport
    def data_for_export(*)
      degrees.includes(application_form: :application_choices).find_each(batch_size: 100).map do |degree|
        candidate = degree.application_form.candidate
        application_form = degree.application_form

        {
          email_address: candidate.email_address,
          name: application_form.full_name,
          phone_number: application_form.phone_number,
          phase: application_form.phase,
          qualification_type: degree.qualification_type,
          subject: degree.subject,
          grade: degree.grade,
          predicted_grade: degree.predicted_grade,
          start_year: degree.start_year,
          award_year: degree.award_year,
          international: degree.international,
          institution_name: degree.institution_name,
          institution_country: degree.institution_country,
          application_status: ProcessState.new(application_form).state,
        }
      end
    end

  private

    def degrees
      ApplicationQualification
      .joins(application_form: :candidate)
      .where(level: 'degree')
      .where.not(candidates: { hide_in_reporting: true }, application_forms: { submitted_at: nil })
      .where(application_forms: { recruitment_cycle_year: 2021 })
      .order('candidates.id')
    end
  end
end

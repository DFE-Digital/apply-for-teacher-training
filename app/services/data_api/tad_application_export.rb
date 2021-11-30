module DataAPI
  class TADApplicationExport
    attr_reader :application_choice

    delegate :course_option, :course, :application_form, to: :application_choice
    delegate :candidate, to: :application_form

    def initialize(application_choice)
      @application_choice = application_choice
    end

    # Documented in app/exports/tad_export.yml
    def as_json
      accrediting_provider = application_choice.accredited_provider || application_choice.provider
      degree = application_form.application_qualifications.find { |q| q.level == 'degree' }
      equality_and_diversity = application_form.equality_and_diversity.to_h

      {
        extract_date: Time.zone.now.iso8601,

        # Internal identifiers
        candidate_id: application_form.candidate.id,
        application_choice_id: application_choice.id,
        application_form_id: application_form.id,

        # State
        status: status,
        phase: application_form.phase,
        submitted_at: application_form.submitted_at.iso8601,

        # Personal information
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        date_of_birth: application_form.date_of_birth,
        email: candidate.email_address,
        postcode: application_form.postcode,
        country: application_form.country,
        nationality: concatenate(nationalities),

        # HESA data
        sex: equality_and_diversity['hesa_sex'],
        disability: equality_and_diversity['hesa_disabilities'],
        ethnicity: equality_and_diversity['hesa_ethnicity'],

        # The candidate's degree
        degree_classification: degree&.grade,
        degree_classification_hesa_code: degree&.grade_hesa_code,

        # Provider
        provider_code: application_choice.provider.code,
        provider_id: application_choice.provider.id,
        provider_name: application_choice.provider.name,
        accrediting_provider_code: accrediting_provider.code,
        accrediting_provider_id: accrediting_provider.id,
        accrediting_provider_name: accrediting_provider.name,

        course_level: course.level,
        program_type: application_choice.course.program_type,
        programme_outcome: application_choice.course.description,
        course_name: application_choice.course.name,
        course_code: application_choice.course.code,
        nctl_subject: concatenate(application_choice.course.subjects.map(&:code)),
      }
    end

  private

    def status
      if application_choice.rejected_by_default?
        'rejected_by_default'
      elsif application_choice.declined_by_default?
        'declined_by_default'
      else
        application_choice.status
      end
    end

    def nationalities
      [
        application_form.first_nationality,
        application_form.second_nationality,
        application_form.third_nationality,
        application_form.fourth_nationality,
        application_form.fifth_nationality,
      ].map { |n| NATIONALITIES_BY_NAME[n] }.compact.uniq
        .sort.partition { |e| %w[GB IE].include? e }.flatten
    end

    def concatenate(array)
      array.to_a.join('|')
    end
  end
end

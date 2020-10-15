module SupportInterface
  class TADApplicationExport
    attr_reader :application_choice

    delegate :course_option, :course, :application_form, to: :application_choice
    delegate :candidate, to: :application_form

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def as_json
      accrediting_provider = course.accredited_provider || application_choice.provider

      # https://ukgovernmentdfe.slack.com/archives/CP18YJXPY/p1602583138300500
      {
        application_choice_id: application_choice.id,
        application_id: application_form.id,
        status: application_choice.status,
        phase: application_form.phase,
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        date_of_birth: application_form.date_of_birth,
        email: candidate.email_address,
        postcode: application_form.postcode,
        country: application_form.country,
        nationality: nationalities,

        sex: application_form.equality_and_diversity.try(:[], 'sex'),
        disability_status: application_form.equality_and_diversity.try(:[], 'disability_status'),
        disabilities: application_form.equality_and_diversity.try(:[], 'disabilities'),
        other_disability: application_form.equality_and_diversity.try(:[], 'other_disability'),
        ethnic_group: application_form.equality_and_diversity.try(:[], 'ethnic_group'),
        ethnic_background: application_form.equality_and_diversity.try(:[], 'ethnic_background'),

        degree_classification: application_form.application_qualifications.find { |q| q.level == 'degree' }.grade,

        provider_code: application_choice.provider.code,
        provider_id: application_choice.provider.id,
        provider_name: application_choice.provider.region_code,

        accrediting_provider_code: accrediting_provider.code,
        accrediting_provider_id: accrediting_provider.id,
        accrediting_provider_name: accrediting_provider.region_code,

        course_level: course.level,

        program_type: application_choice.course.program_type,
        programme_outcome: application_choice.course.description,

        course_name: application_choice.course.name,
        course_code: application_choice.course.code,

        nctl_subject: application_choice.course.subject_codes,
      }
    end

  private

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
  end
end

module ProviderInterface
  class HesaDataExport
    def initialize(provider_ids:)
      @provider_ids = provider_ids
    end

    def call
      applications = ApplicationChoice
        .includes(
          :course,
          :provider,
          :site,
          course_option: { course: %i[provider accredited_provider] },
          application_form: %i[candidate application_qualifications],
        ).where(
          'candidates.hide_in_reporting' => false,
          'status' => ApplicationStateChange::ACCEPTED_STATES,
          'providers.id' => @provider_ids,
          'application_forms.recruitment_cycle_year' => RecruitmentCycle.current_year,
        )

      rows = []

      applications.each do |application|
        first_degree = application.application_form.application_qualifications
          .order(created_at: :asc)
          .find_by(level: 'degree')

        rows << {
          'id' => application.application_form.support_reference,
          'status' => application.status,
          'first name' => application.application_form.first_name,
          'last name' => application.application_form.last_name,
          'date of birth' => application.application_form.date_of_birth,
          'nationality' => application.application_form.first_nationality, # nationality
          'domicile' => application.application_form.country, # domicile
          'email address' => application.application_form.candidate.email_address,
          'recruitment cycle' => application.application_form.recruitment_cycle_year,
          'provider code' => application.provider.code,
          'accredited body' => application.course.accredited_provider&.name,
          'course code' => application.course.code,
          'site code' => application.site.code,
          'study mode' => study_mode(application),
          'SBJCA' => subject_codes(application),
          'QLAIM' => qualification_aim(application),
          'FIRSTDEG' => degrees_completed(application),
          'DEGTYPE' => pad_hesa_value(first_degree, :qualification_type_hesa_code, 3),
          'DEGSBJ' => pad_hesa_value(first_degree, :subject_hesa_code, 4),
          'DEGCLSS' => pad_hesa_value(first_degree, :grade_hesa_code, 2),
          'institution country' => first_degree&.institution_country,
          'DEGSTDT' => first_degree&.start_year,
          'DEGENDDT' => first_degree&.award_year,
          'institution details' => pad_hesa_value(first_degree, :institution_hesa_code, 4),
        }.merge(diversity_information(application))
      end

      header_row ||= rows.first&.keys
      SafeCSV.generate(rows.map(&:values), header_row)
    end

  private

    def pad_hesa_value(degree, method, pad_by)
      return 'no degree' if degree.blank?

      code = degree.send(method)
      return 'no data' if code.blank?

      code.to_s.rjust(pad_by, '0')
    end

    def application_statuses_for(statuses)
      result = []
      statuses.each do |status|
        result << STATUSES[status]
      end
      result.flatten.compact.uniq
    end

    def diversity_information(application)
      return { 'sex' => 'no data', 'disabilities' => 'no data', 'ethnicity' => 'no data' } if application.application_form.equality_and_diversity.blank?

      {
        'sex' => application.application_form.equality_and_diversity['hesa_sex'] || 'not specified',
        'disabilities' => Array(application.application_form.equality_and_diversity.fetch('hesa_disabilities', 'not specified')).join(' '),
        'ethnicity' => application.application_form.equality_and_diversity['hesa_ethnicity'] || 'not specified',
      }
    end

    def csv_headings
      [
        'id', 'status', 'first name', 'last name', 'date of birth', 'nationality', 'domicile', 'email address',
        'recruitment cycle', 'provider code', 'accredited body', 'course code', 'site code', 'study mode', 'SBJCA',
        'QLAIM', 'FIRSTDEG', 'DEGTYPE', 'DEGSBJ', 'DEGCLSS', 'institution country', 'DEGSTDT', 'DEGENDDT',
        'institution details', 'sex', 'disabilities', 'ethnicity'
      ]
    end

    def study_mode(application)
      Hesa::STUDY_MODES.fetch(application.course.study_mode, 'unknown')
    end

    def subject_codes(application)
      application.course.subject_codes.compact.map { |code| Hesa::SubjectCode.find_by_code(code) }.uniq.join(' ')
    end

    def qualification_aim(application)
      return '020' if application.course.name =~ /^QTS/

      '021'
    end

    def degrees_completed(application)
      application.application_form.degrees_completed ? 1 : 0
    end
  end
end

module Hesa
  STUDY_MODES = {
    'full_time' => '01',
    'full_time_or_part_time' => '02',
    'part_time' => '31',
  }.freeze

  class SubjectCode
    # TODO: These are likely incomplete as they are currently based on data we have.
    # Need to discover the source of these subject codes.
    PRIMARY_CODES = %w[00 01 02 03 04 05 06 07].freeze
    LANGUAGE_CODES = %w[15 17 22 24].freeze

    def self.find_by_code(code)
      return if code.blank?
      return '100511' if PRIMARY_CODES.include?(code)
      return '100329' if LANGUAGE_CODES.include?(code)

      mappings[code.ljust(4, '0')]
    end

    def self.mappings
      @mappings ||= YAML.load_file(Rails.root.join('config/hesa/jacs-hecos-subject-mappings.yml'))
    end
  end
end

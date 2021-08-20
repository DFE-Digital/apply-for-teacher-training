module ProviderInterface
  class HesaDataExport
    NO_INFORMATION_GIVEN_STRING = 'no information shared'.freeze

    attr_reader :actor, :recruitment_cycle_year

    def initialize(actor:, recruitment_cycle_year: RecruitmentCycle.current_year)
      @actor = actor
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      applications = GetApplicationChoicesForProviders.call(providers: actor.providers, recruitment_cycle_year: recruitment_cycle_year)
                       .where(
                         'candidates.hide_in_reporting' => false,
                         'status' => ApplicationStateChange::ACCEPTED_STATES,
                       )

      rows = []

      applications.each do |application_choice|
        application = ApplicationChoiceHesaExportDecorator.new(application_choice)

        first_degree_start = year_to_iso8601 first_degree_year(application, :start_year)
        first_degree_end = year_to_iso8601 first_degree_year(application, :award_year)

        rows << {
          'id' => application.application_form.support_reference,
          'status' => application.status,
          'first_name' => application.application_form.first_name,
          'last_name' => application.application_form.last_name,
          'date_of_birth' => application.application_form.date_of_birth,
          'nationality' => application.nationality,
          'domicile' => application.application_form.domicile,
          'email' => application.application_form.candidate.email_address,
          'recruitment_cycle_year' => application.application_form.recruitment_cycle_year,
          'provider_code' => application.provider.code,
          'accredited_provider_name' => application.accredited_provider&.name,
          'course_code' => application.course.code,
          'site_code' => application.site.code,
          'study_mode' => study_mode(application),
          'SBJCA' => subject_codes(application),
          'QLAIM' => qualification_aim(application),
          'FIRSTDEG' => application.degrees_completed_flag,
          'DEGTYPE' => pad_hesa_value(application.first_degree, :qualification_type_hesa_code, 3),
          'DEGSBJ' => pad_hesa_value(application.first_degree, :subject_hesa_code, 4),
          'DEGCLSS' => pad_hesa_value(application.first_degree, :grade_hesa_code, 2),
          'institution_country' => application.first_degree.institution_country,
          'DEGSTDT' => first_degree_start,
          'DEGENDDT' => first_degree_end,
          'institution_details' => pad_hesa_value(application.first_degree, :institution_hesa_code, 4),
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

    def diversity_information(application)
      return { 'sex' => NO_INFORMATION_GIVEN_STRING, 'disabilities' => NO_INFORMATION_GIVEN_STRING, 'ethnicity' => NO_INFORMATION_GIVEN_STRING } if application.application_form.equality_and_diversity.blank?

      return { 'sex' => 'confidential', 'disabilities' => 'confidential', 'ethnicity' => 'confidential' } unless actor.authorisation.can_view_diversity_information?(course: application.course)

      {
        'sex' => application.application_form.equality_and_diversity['hesa_sex'] || NO_INFORMATION_GIVEN_STRING,
        'disabilities' => Array(application.application_form.equality_and_diversity.fetch('hesa_disabilities', NO_INFORMATION_GIVEN_STRING)).join(' '),
        'ethnicity' => application.application_form.equality_and_diversity['hesa_ethnicity'] || NO_INFORMATION_GIVEN_STRING,
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

    def first_degree_year(application, year_type)
      application.first_degree.send year_type
    end

    def year_to_iso8601(year)
      "#{year}-01-01" if year
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

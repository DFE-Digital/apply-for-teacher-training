module ProviderInterface
  class HesaDataExport
    class MissingSubjectCodeHECOSMapping < StandardError; end
    NO_INFORMATION_GIVEN_STRING = 'no information shared'.freeze

    attr_reader :actor, :recruitment_cycle_year

    def initialize(actor:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @actor = actor
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def export_row(application_choice)
      return {} if application_choice.blank?

      application = ApplicationChoiceHesaExportDecorator.new(application_choice)
      first_degree = DegreeExportDecorator.new(application.first_degree)

      {
        'id' => application.id,
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
        'DEGTYPE' => first_degree.qualification_type_hesa_code,
        'DEGSBJ' => first_degree.subject_hesa_code,
        'DEGCLSS' => first_degree.grade_hesa_code,
        'institution_country' => first_degree.institution_country,
        'DEGSTDT' => first_degree.start_year,
        'DEGENDDT' => first_degree.award_year,
        'institution_details' => first_degree.institution_hesa_code,
      }.merge(diversity_information(application))
    end

    def export_data
      GetApplicationChoicesForProviders.call(providers: actor.providers, recruitment_cycle_year:)
        .where('candidates.hide_in_reporting' => false, 'status' => ApplicationStateChange::ACCEPTED_STATES)
        .joins(application_form: :candidate)
    end

  private

    def diversity_information(application)
      return { 'sex' => NO_INFORMATION_GIVEN_STRING, 'disabilities' => NO_INFORMATION_GIVEN_STRING, 'ethnicity' => NO_INFORMATION_GIVEN_STRING } if application.application_form.equality_and_diversity.blank?

      return { 'sex' => 'confidential', 'disabilities' => 'confidential', 'ethnicity' => 'confidential' } unless actor.authorisation.can_view_diversity_information?(course: application.course)

      {
        'sex' => application.application_form.equality_and_diversity['hesa_sex'] || NO_INFORMATION_GIVEN_STRING,
        'disabilities' => Array(application.application_form.equality_and_diversity.fetch('hesa_disabilities', NO_INFORMATION_GIVEN_STRING)).join(' '),
        'ethnicity' => application.application_form.equality_and_diversity['hesa_ethnicity'] || NO_INFORMATION_GIVEN_STRING,
      }
    end

    def study_mode(application)
      Hesa::STUDY_MODES.fetch(application.course.study_mode, 'unknown')
    end

    def subject_codes(application)
      hecos_subject_codes = application.course.subject_codes.compact.map do |code|
        mapping = Hesa::SubjectCode.find_by_code(code)

        mapping
      end

      hecos_subject_codes.compact.uniq.sort.join(' ')
    end

    def qualification_aim(application)
      return '020' if application.course.name =~ /^QTS/

      '021'
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
    CHINESE_LANGUAGE_CODES = ['20'].freeze

    def self.find_by_code(code)
      return if code.blank?
      return '100511' if PRIMARY_CODES.include?(code)
      return '100329' if LANGUAGE_CODES.include?(code)
      return '101165' if CHINESE_LANGUAGE_CODES.include?(code)

      mappings[code.ljust(4, '0')]
    end

    def self.mappings
      @mappings ||= YAML.load_file(Rails.root.join('config/hesa/jacs-hecos-subject-mappings.yml'))
    end
  end
end

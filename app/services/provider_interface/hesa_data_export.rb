require 'csv'

module ProviderInterface
  class HesaDataExport
    STATUSES = {
      'awaiting_decision' => ApplicationStateChange::DECISION_PENDING_STATUSES,
      'offered' => ApplicationStateChange::OFFERED_STATES,
      'accepted' => ApplicationStateChange::ACCEPTED_STATES,
      'conditions_met' => [:recruited],
      'deferred' => [:offer_deferred],
      'declined' => [:offer_declined],
      'rejected' => [:offer_rejected],
      'rejected_automatically' => [],
      'application_withdrawn' => [:withdrawn],
      'offer_withdrawn' => [:offer_withdrawn],
    }.freeze

    def initialize(export_options: {})
      @provider_ids = export_options[:provider_ids]
      @recruitment_cycle_years = export_options.fetch(:recruitment_cycle_years, RecruitmentCycle.current_year)
      @statuses = application_statuses_for(export_options.fetch(:statuses, %w[accepted offered]))
      @include_diversity_information = export_options.fetch(:include_diversity_information, false)
    end

    def call
      applications = ApplicationChoice
        .includes(course_option: { course: :provider }, application_form: %i[candidate application_qualifications])
        .where(
          'candidates.hide_in_reporting' => false,
          'status' => @statuses,
          'providers.id' => @provider_ids,
          'application_forms.recruitment_cycle_year' => @recruitment_cycle_years,
        )

      applications = applications.where('providers.id' => @provider_ids) if @provider_ids.present?

      CSV.generate do |csv|
        csv << csv_headings

        applications.each do |application|
          first_degree = application.application_form.application_qualifications
            .order(created_at: :asc)
            .find_by(level: 'degree')

          csv << [
            application.id, # UUID?
            application.status,
            application.application_form.first_name,
            application.application_form.last_name,
            application.application_form.date_of_birth,
            application.application_form.first_nationality, # nationality
            application.application_form.country, # domicile
            application.application_form.candidate.email_address,
            application.application_form.recruitment_cycle_year,
            application.provider.code,
            application.course.accredited_provider&.name,
            application.course.code,
            application.site.code,
            study_mode(application),
            subject_codes(application),
            qualification_aim(application),
            degrees_completed(application),
            first_degree&.qualification_type_hesa_code.to_s.rjust(3, '0'),
            first_degree&.subject_hesa_code.to_s,
            first_degree&.grade_hesa_code.to_s.rjust(2, '0'),
            first_degree&.institution_country,
            first_degree&.start_year,
            first_degree&.award_year,
            first_degree&.institution_hesa_code.to_s.rjust(4, '0'),
          ] + diversity_information(application)
        end
      end
    end

  private

    def application_statuses_for(statuses)
      result = []
      statuses.each do |status|
        result << STATUSES[status]
      end
      result.flatten.compact.uniq
    end

    def diversity_information(application)
      return [] unless include_diversity_information?
      return ['no data', 'no data', 'no data'] if application.application_form.equality_and_diversity.blank?

      [
        application.application_form.equality_and_diversity['hesa_sex'] || 'not specified',
        (application.application_form.equality_and_diversity['hesa_disabilities'] || ['not specified']).join(' '),
        application.application_form.equality_and_diversity['hesa_ethnicity'] || 'not specified',
      ]
    end

    def csv_headings
      headings = [
        'id', 'status', 'first name', 'last name', 'date of birth', 'nationality', 'domicile', 'email address',
        'recruitment cycle', 'provider code', 'accredited body', 'course code', 'site code', 'study mode', 'SBJCA',
        'QLAIM', 'FIRSTDEG', 'DEGTYPE', 'DEGSBJ', 'DEGCLSS', 'institution country', 'DEGSTDT', 'DEGENDDT',
        'institution details'
      ]
      headings += %w[sex disabilities ethnicity] if include_diversity_information?
      headings
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

    def include_diversity_information?
      @include_diversity_information
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

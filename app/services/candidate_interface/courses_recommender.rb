# frozen_string_literal: true

module CandidateInterface
  class CoursesRecommender
    include Rails.application.routes.url_helpers

    def self.recommended_courses_url(candidate:, locatable: nil)
      new(candidate:, locatable:).recommended_courses_url
    end

    # @param [Provider, Site, ApplicationForm] locatable
    def initialize(candidate:, locatable: nil)
      @candidate = candidate
      @locatable = locatable
    end

    def recommended_courses_url
      find_url_with_query_params
    end

  private

    attr_reader :candidate, :locatable

    def find_url_with_query_params
      uri = URI("#{find_url}results")
      uri.query = query_parameters.to_query unless query_parameters.empty?
      uri.to_s
    end

    def query_parameters
      params = {}

      params[:can_sponsor_visa] = can_sponsor_visa if can_sponsor_visa
      # May need to be converted to use the API
      params[:degree_required] = degree_required if degree_required
      params[:funding_type] = funding_type if funding_type
      params[:qualification] = qualification if qualification
      params[:study_type] = study_type if study_type
      # May need to be converted to use the API
      params[:subjects] = subjects if subjects
      params.merge!(location_params)

      params
    end

    def can_sponsor_visa
      return unless candidate.application_forms.exists?(personal_details_completed: true)

      # Does the Candidate require Courses to sponsor their visa?
      # Returns true if the Candidate does not have the right to work or study in the UK
      requires_visa = candidate.application_forms.exists?(right_to_work_or_study: 'no')
      requires_visa.to_s # 'true' or 'false'
    end

    def degree_required
      return unless candidate.application_forms.exists?(degrees_completed: true)

      candidate_degree_grades = candidate.degree_qualifications.pluck(:grade)

      return 'not_required' if candidate_degree_grades.empty?

      # What Course degree entry requirements can the Candidate meet?
      return 'show_all_courses' if candidate_degree_grades.include?('First-class honours')
      return 'two_two' if candidate_degree_grades.include?('Lower second-class honours (2:2)')
      return 'third_class' if candidate_degree_grades.include?('Third-class honours')

      # The Grades don't match any of the above,
      # so we assume the Candidate can meet any degree entry requirement
      'show_all_courses'
    end

    def funding_type
      # Does the Candidate have any submitted Applications?
      return unless candidate.application_choices.exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

      # What Course funding types has the Candidate applied for?
      funding_types = candidate.application_choices
                               .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                               .joins(course_option: :course)
                               .pluck('courses.funding_type')
                               .compact_blank
                               .uniq
                               .sort

      # salary,apprenticeship,fee
      funding_types.join(',')
    end

    def qualification
      # Does the Candidate have any submitted Applications?
      return unless candidate.application_choices.exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

      # What Course qualification types has the Candidate applied for?
      qualifications = candidate.application_choices.where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                                .joins(course_option: :course)
                                .pluck('courses.qualifications')
                                .flatten
                                .compact_blank
                                .uniq
                                .sort
      # pgde,pgce,pgce_with_qts,pgde_with_qts,qts
      qualifications.join(',')
    end

    def study_type
      # Does the Candidate have any submitted Applications?
      return unless candidate.application_choices.exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

      # What Course study types has the Candidate applied for?
      study_modes = candidate.application_choices.where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                             .joins(course_option: :course)
                             .pluck('course_options.study_mode')
                             .compact_blank
                             .uniq
                             .sort
      # full_time,part_time
      study_modes.join(',')
    end

    def subjects
      # Does the Candidate have any submitted Applications?
      return unless candidate.application_choices.exists?(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

      # What Course subjects has the Candidate applied for?
      # subject codes
      candidate.application_choices.where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                            .joins(course_option: { course: :subjects })
                            .pluck('subjects.code')
                            .compact_blank
                            .uniq
                            .sort
    end

    def location_params
      location_params = {
        latitude: locatable&.latitude,
        longitude: locatable&.longitude,
        radius: '10',
      }
      return {} unless location_params.values.all?(&:present?)

      location_params
    end
  end
end

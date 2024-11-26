# frozen_string_literal: true

module CandidateInterface
  class CoursesRecommender
    include Rails.application.routes.url_helpers

    def self.recommended_courses_url(candidate:)
      new(candidate:).recommended_courses_url
    end

    def initialize(candidate:)
      @candidate = candidate
    end

    def recommended_courses_url
      find_url_with_query_params
    end

  private

    attr_reader :candidate

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

      params

      # {
      #   can_sponsor_visa: ,
      #   degree_required: 'show_all_courses', # show_all_courses two_two third_class not_required
      #   funding_type: 'salary,apprenticeship,fee',
      #   latitude: nil, # all 3 of these are for location
      #   longitude: nil,
      #   qualification: %w[
      #     pgde
      #     pgce
      #     pgce_with_qts
      #     pgde_with_qts
      #     qts
      #   ],
      #   radius: 20,
      #   study_type: %w[full_time part_time],
      #   subjects: %w[00 01], # subject codes
      # }
    end

    def can_sponsor_visa
      return unless candidate.application_forms.any?(&:personal_details_completed?)

      # Does the Candidate require Courses to sponsor their visa?
      # Returns true if the Candidate does not have the right to work or study in the UK
      requires_visa = candidate.application_forms.any? { |application_form| application_form.right_to_work_or_study == 'no' }
      requires_visa.to_s # 'true' or 'false'
    end

    def degree_required
      return unless candidate.application_forms.any?(&:degrees_completed?)

      candidate_degree_grades = candidate.application_forms.flat_map(&:degree_qualifications).map(&:grade)

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
      funding_types = candidate.application_choices.where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
                               .joins(course_option: :course)
                               .pluck('courses.funding_type')
                               .compact_blank
                               .uniq

      # salary,apprenticeship,fee
      funding_types.join(',')
    end
  end
end

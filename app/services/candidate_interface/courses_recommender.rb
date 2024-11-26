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
      uri = URI(find_url)
      uri.query = query_parameters.to_query unless query_parameters.empty?
      uri.to_s
    end

    def query_parameters
      params = {}

      params[:can_sponsor_visa] = can_sponsor_visa if can_sponsor_visa
      params[:degree_required] = degree_required if degree_required

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
      # What level of degree does the Candidate have?


    end
  end
end

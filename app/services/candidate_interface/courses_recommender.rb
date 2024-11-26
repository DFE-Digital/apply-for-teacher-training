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

    def recommend?
      # Decides whether to recommend courses to the candidate
      false
    end

    def find_url_with_query_params
      return unless recommend?

      uri = URI(find_url)
      uri.query = query_parameters.to_query
      uri.to_s
    end

    def query_parameters
      {
        can_sponsor_visa: true,
        degree_required: 'show_all_courses', # show_all_courses two_two third_class not_required
        funding_type: 'salary,apprenticeship,fee',
        latitude: nil, # all 3 of these are for location
        longitude: nil,
        qualification: [
          'pgde',
          'pgce',
          'pgce_with_qts',
          'pgde_with_qts',
          'qts',
        ],
        radius: 20,
        study_type: ['full_time', 'part_time'],
        subjects: ['00', '01'], # subject codes
      }
    end
  end
end

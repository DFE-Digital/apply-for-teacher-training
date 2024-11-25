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
      uri.query = query_params.to_query
      uri.to_s
    end

    def query_params
      {
        can_sponsor_visa: true,
      }
    end
  end
end

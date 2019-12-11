module CandidateInterface
  class ContentController < ApplicationController
    include ContentHelper

    def accessibility
      render_content_page :accessibility
    end

    def privacy_policy
      render_content_page :privacy_policy
    end

    def cookies_candidate
      render_content_page :cookies_candidate
    end

    def terms_candidate
      render_content_page :terms_candidate
    end

    def providers
      @courses_by_provider = Course
        .visible_to_candidates
        .includes(:provider)
        .group_by { |c| c.provider.name }
        .sort_by { |provider_name, _| provider_name }
    end
  end
end

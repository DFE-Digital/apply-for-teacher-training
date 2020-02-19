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
      provider_courses = Struct.new(:provider_name, :courses)

      @courses_by_provider = Course
        .open_on_apply
        .includes(:provider)
        .group_by { |c| c.provider.name }
        .sort_by { |provider_name, _| provider_name }
        .map { |provider_name, courses| provider_courses.new(provider_name, courses) }
    end
  end
end

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

    ProviderCourses = Struct.new(:provider_name, :courses)
    RegionProviderCourses = Struct.new(:region_code, :provider_name, :courses)

    def providers
      @courses_by_provider_and_region = courses_grouped_by_provider_and_region
    end

  private

    def courses_grouped_by_provider_and_region
      Course
        .open_on_apply
        .includes(:provider)
        .order('providers.region_code', 'providers.name')
        .group_by { |course| [course.provider.region_code, course.provider.name] }
        .map { |region_provider, courses| RegionProviderCourses.new(region_provider[0], region_provider[1], courses) }
        .group_by(&:region_code)
    end
  end
end

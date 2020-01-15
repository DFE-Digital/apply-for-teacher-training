module SupportInterface
  class ProviderCoursesTableComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(provider:, courses:)
      @provider = provider
      @courses = courses
    end

    def course_rows
      courses.order(:name).map do |course|
        {
          course_link: govuk_link_to(course.name_and_code, support_interface_course_path(course)),
          provider_link: govuk_link_to(course.provider.name_and_code, support_interface_provider_path(course.provider)),
          level: course.level,
          recruitment_cycle_year: course.recruitment_cycle_year,
          apply_from_find_link: link_to_apply_from_find_page(course),
          link_to_find_course_page: link_to_find_course_page(course),
        }
      end
    end

    def providers_vary?
      @providers_vary ||= courses.any? { |c| c.provider != provider }
    end

  private

    attr_reader :provider, :courses

    def link_to_apply_from_find_page(course)
      if course.exposed_in_find? && course.open_on_apply?
        govuk_link_to 'Apply from Find (DfE & UCAS)', candidate_interface_apply_from_find_path(providerCode: course.provider.code, courseCode: course.code)
      elsif course.exposed_in_find?
        govuk_link_to 'Apply from Find (UCAS only)', candidate_interface_apply_from_find_path(providerCode: course.provider.code, courseCode: course.code)
      end
    end

    def link_to_find_course_page(course)
      if course.exposed_in_find?
        govuk_link_to 'Find course page', "https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{course.provider.code}/#{course.code}"
      end
    end
  end
end

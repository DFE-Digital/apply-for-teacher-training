module SupportInterface
  class ProviderCoursesTableComponent < ViewComponent::Base
    include ViewHelper

    def initialize(provider:, courses:)
      @provider = provider
      @courses = courses
    end

    def course_rows
      courses.map do |course|
        {
          id: course.id,
          course_link: govuk_link_to(course.name_and_code, support_interface_course_path(course)),
          provider_link: link_to_provider_page(course.provider),
          recruitment_cycle_year: course.recruitment_cycle_year,
          status_tag: status_tag(course),
          accredited_body: link_to_provider_page(course.accredited_provider),
          accredited_body_onboarded: course.accredited_provider&.onboarded?,
        }
      end
    end

    def providers_vary?
      @providers_vary ||= courses.any? { |c| c.provider != provider }
    end

    def accredited_bodies_vary?
      @accredited_bodies_vary ||= courses.any? { |c| c.accredited_provider && c.accredited_provider != provider }
    end

  private

    attr_reader :provider, :courses

    def status_tag(course)
      if course.recruitment_cycle_year == RecruitmentCycle.next_year
        govuk_tag(text: 'Unpublished', colour: 'blue')
      elsif course.open?
        govuk_tag(text: 'Open', colour: 'green')
      elsif !course.exposed_in_find?
        govuk_tag(text: 'Hidden in Find', colour: 'grey')
      elsif course.application_status_closed?
        govuk_tag(text: 'Closed by Provider', colour: 'blue')
      else # rubocop:disable Lint/DuplicateBranch
        govuk_tag(text: 'Unpublished', colour: 'blue')
      end
    end

    def link_to_provider_page(provider)
      if provider
        govuk_link_to(
          provider.name_and_code,
          support_interface_provider_path(provider),
        )
      end
    end
  end
end

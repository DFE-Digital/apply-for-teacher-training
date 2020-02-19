module ProviderInterface
  class OfferedCourseComponent < ActionView::Component::Base
    attr_reader :application_choice, :display

    def initialize(application_choice:, display: :course)
      @application_choice = application_choice
      @display = display
    end

    def course_option
      application_choice.offered_course_option || application_choice.course_option
    end

    def course
      course_option.course
    end

    def site
      course_option.site
    end

    def provider_name
      course.provider.name
    end

    def course_name_and_code
      course.name_and_code
    end

    def course_site_details
      address = site.full_address
      if address.present?
        [site.name, address].join(', ')
      else
        site.name
      end
    end
  end
end

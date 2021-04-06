module ProviderInterface
  class OfferSummaryListComponent < ViewComponent::Base
    include ViewHelper
    include ProviderInterface::StatusBoxComponents::CourseRows

    attr_reader :application_choice, :header, :options

    def initialize(application_choice:, header: 'Your offer', options: {})
      @application_choice = application_choice
      @course_option = application_choice.current_course_option
      @header = header
      @change_provider_path = options[:change_provider_path]
      @change_course_path = options[:change_course_path]
      @change_study_mode_path = options[:change_study_mode_path]
      @change_course_option_path = options[:change_course_option_path]
    end

    def rows
      [
        {
          key: 'Candidate name',
          value: application_choice.application_form.full_name,
        },
      ] + add_change_links_to(course_rows(course_option: application_choice.current_course_option))
    end

  private

    def add_change_links_to(rows)
      rows.map do |row|
        case row[:key]
        when 'Provider'
          row.merge(change_path: @change_provider_path, action: 'training provider')
        when 'Course'
          row.merge(change_path: @change_course_path, action: 'course')
        when 'Full time or part time'
          row.merge(change_path: @change_study_mode_path, action: 'to full time or part time')
        when 'Location'
          row.merge(change_path: @change_course_option_path, action: 'location')
        else
          row
        end
      end
    end
  end
end

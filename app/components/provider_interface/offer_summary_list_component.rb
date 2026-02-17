module ProviderInterface
  class OfferSummaryListComponent < ApplicationComponent
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
        when 'Training provider'
          row.merge(action: { href: @change_provider_path })
        when 'Course'
          row.merge(action: { href: @change_course_path })
        when 'Full time or part time'
          row.merge(action: { href: @change_study_mode_path, visually_hidden_text: 'if full time or part time' })
        when 'Location'
          row.merge(action: { href: @change_course_option_path })
        else
          row
        end
      end
    end
  end
end

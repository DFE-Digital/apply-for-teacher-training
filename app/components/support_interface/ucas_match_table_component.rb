module SupportInterface
  class UCASMatchTableComponent < ViewComponent::Base
    include ViewHelper

    DISPLAYED_STATUSES =
      {
        'awaiting_provider_decision' => 'Awaiting provider decision',
        'offer' => 'Offer received',
        'rejected' => 'Application rejected',
        'declined' => 'Offer declined',
        'withdrawn' => 'Withdrawn',
        'offer_withdrawn' => 'Withdrawn',
        'conditions_not_met' => 'Withdrawn',
        'cancelled' => 'Withdrawn',
        'pending_conditions' => 'Offer received',
      }.freeze

    def initialize(match)
      @match = match
    end

    def table_rows
      candidates_course_choices.map do |course|
        row_data = { course_choice_details: course_choice_details(course) }

        matched_applications_for_course(course).each do |application|
          status = displayed_status(application)
          if application.ucas_scheme?
            row_data.merge!(status_on_ucas: status)
          elsif application.dfe_scheme?
            row_data.merge!(status_on_apply: status)
          end
        end

        row_data
      end
    end

  private

    def candidates_course_choices
      ucas_matched_applications.map(&:course).uniq
    end

    def ucas_matched_applications
      @match.matching_data.map do |data|
        UCASMatchedApplication.new(data)
      end
    end

    def matched_applications_for_course(course)
      ucas_matched_applications.select { |application| application.course == course }
    end

    def course_choice_details(course)
      "#{course.code} — #{course.name} — #{course.provider.name}"
    end

    def displayed_status(ucas_matched_application)
      DISPLAYED_STATUSES[ucas_matched_application.status]
    end
  end
end

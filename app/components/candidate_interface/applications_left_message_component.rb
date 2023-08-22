module CandidateInterface
  class ApplicationsLeftMessageComponent < ViewComponent::Base
    attr_reader :application_form

    delegate :submitted?,
             :maximum_number_of_course_choices?,
             :maximum_number_of_course_choices,
             :applications_left,
             to: :application_form

    def initialize(application_form)
      @application_form = application_form
      @completed_application_form_details = CandidateInterface::CompletedApplicationForm.new(application_form:)
    end

    def messages
      [maximum_number_of_applications_message, incomplete_details_message].flatten.compact
    end

  private

    def incomplete_details_message
      t('candidate_interface.applications_left_message.incomplete_details_message') unless @completed_application_form_details.valid?
    end

    def maximum_number_of_applications_message
      return [default_message] unless submitted?

      if maximum_number_of_course_choices?
        [
          t('candidate_interface.applications_left_message.can_not_add_more_heading', maximum_number_of_course_choices:),
          t('candidate_interface.applications_left_message.can_not_add_more_message'),
        ]
      else
        [t('candidate_interface.applications_left_message.can_add_more', applications_left:)]
      end
    end

    def default_message
      t('candidate_interface.applications_left_message.default_message', maximum_number_of_course_choices:)
    end
  end
end

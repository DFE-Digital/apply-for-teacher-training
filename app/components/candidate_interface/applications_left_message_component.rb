module CandidateInterface
  class ApplicationsLeftMessageComponent < ViewComponent::Base
    attr_reader :application_form

    delegate :submitted?,
             :cannot_add_more_choices?,
             :number_of_slots_left,
             to: :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def messages
      [maximum_number_of_applications_message, inactive_application_message].flatten.compact
    end

  private

    def inactive_application_message
      t('candidate_interface.applications_left_message.inactive_application_message')
    end

    def maximum_number_of_applications_message
      return [default_message] unless submitted?

      if cannot_add_more_choices?
        [
          t('candidate_interface.applications_left_message.can_not_add_more_heading', maximum_number_of_course_choices: ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES),
          t('candidate_interface.applications_left_message.can_not_add_more_message'),
        ]
      else
        [t('candidate_interface.applications_left_message.can_add_more', count: number_of_slots_left)]
      end
    end

    def default_message
      t('candidate_interface.applications_left_message.default_message', maximum_number_of_course_choices: ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES)
    end
  end
end

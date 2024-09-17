module CandidateInterface
  class CancelUnsubmittedApplicationAtEndOfCycle
    def initialize(application_form)
      @application_form = application_form
    end

    def call
      @application_form.application_choices.unsubmitted.each do |application_choice|
        ApplicationStateChange.new(application_choice).reject_at_end_of_cycle!
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.warn "Unable to reject application #{application_choice.id}. Error: #{e}"
      end
    end
  end
end

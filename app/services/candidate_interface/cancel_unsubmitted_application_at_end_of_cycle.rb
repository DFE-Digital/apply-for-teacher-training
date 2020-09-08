module CandidateInterface
  class CancelUnsubmittedApplicationAtEndOfCycle
    def initialize(application_form)
      @application_form = application_form
    end

    def call
      @application_form.application_choices.each do |application_choice|
        ApplicationStateChange.new(application_choice).reject_at_end_of_cycle!
      end
    end
  end
end

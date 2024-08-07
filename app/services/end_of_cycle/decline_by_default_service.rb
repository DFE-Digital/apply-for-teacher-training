module EndOfCycle
  class DeclineByDefaultService
    def initialize(application_form)
      @application_form = application_form
    end

    def call
      application_choices_to_decline.find_each do |application_choice|
        ActiveRecord::Base.transaction do
          application_choice.update!(
            declined_by_default: true,
            declined_at: Time.zone.now,
            withdrawn_or_declined_for_candidate_by_provider: false,
          )
          ApplicationStateChange.new(application_choice).decline_by_default!
        end
      end
    end

  private

    def application_choices_to_decline
      @application_form.application_choices.offer
    end
  end
end

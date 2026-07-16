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
      if run_winter_decline_by_default?
        @application_form
          .application_choices
          .course_starts_after_september(
            @application_form.recruitment_cycle_year,
          )
      else
        @application_form
          .application_choices
          .course_start_in_september(
            @application_form.recruitment_cycle_year,
          )
      end.offer
    end

    def run_winter_decline_by_default?
      @application_form.recruitment_cycle_timetable.after_winter_decline_by_default?
    end
  end
end

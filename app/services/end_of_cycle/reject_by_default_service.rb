module EndOfCycle
  class RejectByDefaultService
    REJECTABLE_STATUSES = ApplicationStateChange::ApplicationState.state_ids(:redactable).freeze

    def initialize(application_form)
      @application_form = application_form
    end

    def call
      application_choices_to_reject.find_each do |application_choice|
        ActiveRecord::Base.transaction do
          reject_application_choice!(application_choice)
          cancel_interviews!(application_choice)
        end
      end
    end

  private

    def application_choices_to_reject
      @application_choices_to_reject ||= if run_winter_reject_by_default?
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
                                         end.where(status: REJECTABLE_STATUSES)
    end

    def run_winter_reject_by_default?
      @application_form.recruitment_cycle_timetable.after_winter_reject_by_default?
    end

    def reject_application_choice!(application_choice)
      ApplicationStateChange.new(application_choice).reject_by_default!
      application_choice.update!(
        rejected_by_default: true,
        rejected_at: Time.zone.now,
      )
    end

    def cancel_interviews!(application_choice)
      cancellation_reason = I18n.t('interview_cancellation.reason.application_rejected')
      application_choice.interviews.kept.upcoming_not_today.each do |interview|
        interview.update!(cancellation_reason:, cancelled_at: Time.zone.now)
        CandidateMailer.interview_cancelled(application_choice, interview, cancellation_reason).deliver_later
      end
    end
  end
end

module EndOfCycle
  class RejectByDefaultService
    REJECTABLE_STATUSES = ApplicationStateChange::DECISION_PENDING_AND_INACTIVE_STATUSES.freeze

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
      @application_choices_to_reject ||= @application_form.application_choices.where(status: REJECTABLE_STATUSES)
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

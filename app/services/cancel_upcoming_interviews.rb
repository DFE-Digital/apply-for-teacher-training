class CancelUpcomingInterviews
  include ImpersonationAuditHelper

  def initialize(actor:, application_choice:, cancellation_reason:)
    @actor = actor
    @application_choice = application_choice
    @cancellation_reason = cancellation_reason
  end

  def call!
    audit(actor) do
      cancel_interviews!
      send_notifications
    end
  end

private

  attr_reader :actor, :application_choice, :cancellation_reason

  def interviews_to_cancel
    @interviews_to_cancel ||= application_choice.interviews.kept.upcoming_not_today
  end

  def cancel_interviews!
    ActiveRecord::Base.transaction do
      interviews_to_cancel.each do |interview|
        interview.update!(cancellation_reason: cancellation_reason, cancelled_at: Time.zone.now)
      end
    end
  end

  def send_notifications
    interviews_to_cancel.each do |interview|
      CandidateMailer.interview_cancelled(application_choice, interview, cancellation_reason).deliver_later
    end
  end
end

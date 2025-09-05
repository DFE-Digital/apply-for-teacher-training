class CandidateInterface::ReferenceSendReminderComponent < ApplicationComponent
  attr_accessor :reference, :reference_actions_policy
  delegate :can_send_reminder?, to: :reference_actions_policy
  delegate :reminder_sent_at, to: :reference

  def initialize(reference)
    @reference = reference
    @reference_actions_policy = ReferenceActionsPolicy.new(@reference)
  end

  def remind_again_at
    reminder_sent_at + TimeLimitConfig.minimum_hours_between_chaser_emails.hours
  end
end

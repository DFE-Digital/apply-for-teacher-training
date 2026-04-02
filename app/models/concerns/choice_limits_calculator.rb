module ChoiceLimitsCalculator
  extend ActiveSupport::Concern

  IN_PROGRESS_LIMIT = 4
  UNSUCCESSFUL_RETRY_LIMIT = 15
  MID_CYCLE_UNSUCCESSFUL_RETRY_LIMIT = 0

  delegate :unsuccessful_retry_limit, :in_progress_limit, :total_application_limit, to: :limits

  Limits = Data.define(:in_progress_limit, :unsuccessful_retry_limit) do
    def total_application_limit = unsuccessful_retry_limit + in_progress_limit
  end

  def limits
    @limits ||= if mid_cycle_cap_applies?
                  Limits.new(
                    unsuccessful_retry_limit: MID_CYCLE_UNSUCCESSFUL_RETRY_LIMIT,
                    in_progress_limit: IN_PROGRESS_LIMIT,
                  )
                else
                  Limits.new(
                    unsuccessful_retry_limit: UNSUCCESSFUL_RETRY_LIMIT,
                    in_progress_limit: IN_PROGRESS_LIMIT,
                  )
                end
  end

  def unsuccessful_count
    application_choices.count(&:application_unsuccessful?)
  end

  def in_progress_count
    application_choices.count(&:application_in_progress?)
  end

  def total_submitted_count
    unsuccessful_count + in_progress_count
  end

  def draft_count
    application_choices.count(&:unsubmitted?)
  end

  def cannot_submit_more_choices?
    unsuccessful_limit_reached? || in_progress_limit_reached?
  end

  def can_submit_more_choices?
    !cannot_submit_more_choices?
  end

  def unsuccessful_limit_reached?
    if unsuccessful_retry_limit >= in_progress_limit
      unsuccessful_count >= unsuccessful_retry_limit
    else
      total_submitted_application_limit_reached? && unsuccessful_count > unsuccessful_retry_limit
    end
  end

  def total_submitted_application_limit_reached?
    total_submitted_count >= total_application_limit
  end

  def in_progress_limit_reached?
    in_progress_count >= in_progress_limit
  end

  def mid_cycle_cap_applies?
    FeatureFlag.active?(:mid_cycle_cap) &&
      # The cap only applies to people who were unsubmitted at the time the cap was introduced
      (submitted_at.nil? || submitted_at.after?(FeatureFlag.activated_at(:mid_cycle_cap)))
  end

  def can_add_more_choices?
    can_submit_more_choices? && number_of_slots_left.positive?
  end

  def cannot_add_more_choices?
    !can_add_more_choices?
  end

  def number_of_slots_left
    slots_left = in_progress_limit - in_progress_count # in progress take up a slot
    slots_left -= draft_count # drafts take up a slot
    slots_left -= [(unsuccessful_count - unsuccessful_retry_limit), 0].max # unsuccessful above the retry limit take up a slot
    [slots_left, 0].max
  end
end

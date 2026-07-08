module ChoiceLimitsCalculator
  extend ActiveSupport::Concern

  IN_PROGRESS_LIMIT = 4
  TOTAL_CHOICE_LIMIT = 15
  MID_CYCLE_UNSUCCESSFUL_RETRY_LIMIT = 0

  delegate :in_progress_limit, :total_application_limit, to: :limits

  Limits = Data.define(:in_progress_limit, :total_application_limit)

  def limits
    @limits ||= Limits.new(
      total_application_limit: TOTAL_CHOICE_LIMIT,
      in_progress_limit: IN_PROGRESS_LIMIT,
    )
  end

  alias unsuccessful_retry_limit total_application_limit

  def unsuccessful_count
    application_choices.count(&:application_unsuccessful?)
  end

  def in_progress_count
    application_choices.count(&:application_in_progress?)
  end

  def total_submitted_count
    unsuccessful_count + in_progress_count
  end

  def total_applications_count
    application_choices.count
  end

  def draft_count
    application_choices.count(&:unsubmitted?)
  end

  def cannot_submit_more_choices?
    if recruitment_cycle_year > 2026
      total_submitted_application_limit_reached? || in_progress_limit_reached?
    else
      unsuccessful_limit_reached? || in_progress_limit_reached?
    end
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

  def total_applications_reached?
    total_applications_count >= total_application_limit
  end

  def in_progress_limit_reached?
    in_progress_count >= in_progress_limit
  end

  def can_add_more_choices?
    if recruitment_cycle_year > 2026
      !total_applications_reached? && can_submit_more_choices? && number_of_slots_left.positive?
    else
      can_submit_more_choices? && number_of_slots_left.positive?
    end
  end

  def cannot_add_more_choices?
    !can_add_more_choices?
  end

  def number_of_slots_left
    return 0 if total_applications_reached? && recruitment_cycle_year > 2026

    slots_left = in_progress_limit - in_progress_count # in progress take up a slot
    slots_left -= draft_count # drafts take up a slot
    slots_left -= [(unsuccessful_count - unsuccessful_retry_limit), 0].max # unsuccessful above the retry limit take up a slot
    slots_left = [slots_left, 0].max
    return slots_left if recruitment_cycle_year <= 2026 || (total_applications_count + slots_left) < total_application_limit

    total_application_limit - total_applications_count
  end
end

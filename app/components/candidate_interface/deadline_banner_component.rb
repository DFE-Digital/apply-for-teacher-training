class CandidateInterface::DeadlineBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(phase:, flash_empty:)
    @phase = phase
    @flash_empty = flash_empty
  end

  def deadline
    apply_1? ? apply_1_deadline : apply_2_deadline
  end

  def render?
    flash_empty &&
      (show_apply_1_deadline_banner? || show_apply_2_deadline_banner?)
  end

private

  def show_apply_1_deadline_banner?
    apply_1? &&
      CycleTimetable.show_apply_1_deadline_banner? &&
      FeatureFlag.active?(:deadline_notices)
  end

  def show_apply_2_deadline_banner?
    apply_2? &&
      CycleTimetable.show_apply_2_deadline_banner? &&
      FeatureFlag.active?(:deadline_notices)
  end

  def apply_1?
    phase == 'apply_1'
  end

  def apply_2?
    phase == 'apply_2'
  end

  def apply_1_deadline
    CycleTimetable.date(:apply_1_deadline).to_s(:day_and_month)
  end

  def apply_2_deadline
    CycleTimetable.date(:apply_2_deadline).to_s(:day_and_month)
  end
end

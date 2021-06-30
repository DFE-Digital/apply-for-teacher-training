class CandidateInterface::ReopenBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(phase:, flash_empty:)
    @phase = phase
    @flash_empty = flash_empty
  end

  def render?
    flash_empty &&
      (show_apply_1_reopen_banner? || show_apply_2_reopen_banner?)
  end

private

  def show_apply_1_reopen_banner?
    apply_1? &&
      CycleTimetable.between_cycles_apply_1?
  end

  def show_apply_2_reopen_banner?
    apply_2? &&
      CycleTimetable.between_cycles_apply_2?
  end

  def apply_1?
    phase == 'apply_1'
  end

  def apply_2?
    phase == 'apply_2'
  end

  def reopen_date
    CycleTimetable.date(:apply_reopens).to_s(:govuk_date)
  end
end

class CandidateInterface::ReopenBannerComponent < ViewComponent::Base
  attr_accessor :flash_empty

  delegate :after_apply_deadline?,
           :academic_year_range_name,
           :apply_reopens_at,
           :next_available_academic_year_range,
           to: :@application_form, prefix: :application_form

  def initialize(flash_empty:, application_form:)
    @flash_empty = flash_empty
    @application_form = application_form
  end

  def render?
    flash_empty && show_apply_reopen_banner?
  end

private

  def show_apply_reopen_banner?
    application_form_after_apply_deadline?
  end

  def academic_year_range_name
    application_form_academic_year_range_name
  end

  def date_and_time_next_apply_opens
    application_form_apply_reopens_at.to_fs(:govuk_date_time_time_first)
  end

  def next_academic_year_range_name
    application_form_next_available_academic_year_range
  end
end

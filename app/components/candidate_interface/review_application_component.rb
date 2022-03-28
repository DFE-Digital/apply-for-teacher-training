class CandidateInterface::ReviewApplicationComponent < ViewComponent::Base
  attr_accessor :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

private

  def reopen_date
    Time.zone.now < CycleTimetable.date(:apply_opens) ? CycleTimetable.apply_opens.to_fs(:govuk_date) : CycleTimetable.apply_reopens.to_fs(:govuk_date)
  end
end

class SupportInterface::QualificationsComponent < ApplicationComponent
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def editable
    @editable ||= SupportInterface::CandidatePolicy.new(helpers.current_support_user, nil).edit?
  end
end

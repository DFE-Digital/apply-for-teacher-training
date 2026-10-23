class SupportInterface::QualificationsComponent < ApplicationComponent
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def editable
    @editable ||= helpers.current_support_user.can_edit_applications?
  end
end

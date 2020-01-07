class QualificationsComponent < ActionView::Component::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end
end

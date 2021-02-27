# NOTE: This component is used by both provider and support UIs
class WorkHistoryComponent < ViewComponent::Base
  def initialize(application_form:)
    self.application_form = application_form
  end

  def history
    @history ||= WorkHistoryWithBreaks.new(@application_form).timeline
  end

  def render?
    history.present?
  end

private

  attr_accessor :application_form
end

# NOTE: This component is used by both provider and support UIs
class WorkHistoryComponent < ViewComponent::Base
  def initialize(application_form:)
    @application_form = application_form
    @work_history_with_breaks ||= WorkHistoryWithBreaks.new(application_form)
  end

  def history
    @history ||= work_history_with_breaks.timeline
  end

  def render?
    history.present?
  end

private

  attr_accessor :application_form, :work_history_with_breaks
end

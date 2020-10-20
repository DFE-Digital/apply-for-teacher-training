class ReferenceHistoryComponent < ViewComponent::Base
  attr_reader :reference

  def initialize(reference)
    @reference = reference
  end

  def history
    ReferenceHistory.new(reference).all_events
  end

  def event_title(event)
    event.name.humanize
  end

private

  def date_format(datetime)
    datetime.to_s(:govuk_date_and_time)
  end
end

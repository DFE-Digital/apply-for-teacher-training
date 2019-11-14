class ErrorSummaryComponent < ActionView::Component::Base
  validates :messages, presence: true

  def initialize(messages:)
    @messages = messages
  end

private

  attr_reader :messages
end

class ErrorFlashComponent < ActionView::Component::Base
  validates :message, presence: true

  def initialize(message:)
    @message = message
  end

private

  attr_reader :message
end

class SuccessSummaryComponent < ActionView::Component::Base
  validates :summary, presence: true

  def initialize(summary:)
    @summary = summary
  end

private

  attr_reader :summary
end

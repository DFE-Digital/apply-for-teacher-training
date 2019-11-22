class SectionMissingBannerComponent < ActionView::Component::Base
  validates :text, presence: true

  def initialize(text:)
    @text = text
  end

  attr_reader :text
end

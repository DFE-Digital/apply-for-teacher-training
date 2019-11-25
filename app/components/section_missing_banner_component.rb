class SectionMissingBannerComponent < ActionView::Component::Base
  validates :text, :section, presence: true

  def initialize(text:, section:)
    @text = text
    @section = section
  end

  attr_reader :text, :section
end

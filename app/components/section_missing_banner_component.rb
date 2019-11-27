class SectionMissingBannerComponent < ActionView::Component::Base
  validates :section, :section_path, :text, presence: true

  def initialize(section:, section_path:, text:)
    @section = section
    @section_path = section_path
    @text = text
  end

  attr_reader :section, :section_path, :text
end

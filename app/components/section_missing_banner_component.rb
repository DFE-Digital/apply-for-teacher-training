class SectionMissingBannerComponent < ActionView::Component::Base
  validates :section, :section_path, presence: true

  def initialize(section:, section_path:, text: t("review_application.#{section}.incomplete"), error: false)
    @section = section
    @section_path = section_path
    @text = text
    @error = error
  end

  attr_reader :section, :section_path, :text
end

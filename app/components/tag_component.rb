class TagComponent < ViewComponent::Base
  def initialize(text:, type:)
    @text = text
    @css_classes = css_classes(type)
  end

private

  attr_reader :text

  def css_classes(colour)
    colour ? "govuk-tag--#{colour}" : ''
  end
end

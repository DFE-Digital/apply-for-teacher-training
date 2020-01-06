class TagComponent < ActionView::Component::Base
  def initialize(text:, type:)
    @text = text
    @css_classes = css_classes(type)
  end

private

  attr_reader :text

  def css_classes(colour)
    colour ? "app-tag--#{colour}" : ''
  end
end

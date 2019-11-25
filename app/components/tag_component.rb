class TagComponent < ActionView::Component::Base
  def initialize(text:, type:)
    @text = text
    @css_classes = css_classes(type)
  end

private

  attr_reader :text

  def css_classes(type)
    tag_css_class = case type
                    when :danger
                      'app-tag--danger'
                    when :secondary
                      'app-tag--secondary'
                    when :info
                      'app-tag--info'
                    when :info_unfilled
                      'app-tag--info-unfilled'
                    when :warning
                      'app-tag--warning'
                    when :primary_unfilled
                      'app-tag--primary-unfilled'
                    else
                      'app-tag--primary'
                    end

    "govuk-tag #{tag_css_class}"
  end
end

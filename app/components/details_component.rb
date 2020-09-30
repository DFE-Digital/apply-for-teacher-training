class DetailsComponent < ViewComponent::Base
  include ViewHelper
  attr_reader :summary_text, :details_body, :open

  def initialize(summary_text:, details_body:, additional_css_classes: nil, open: false)
    @summary_text = summary_text
    @details_body = details_body.html_safe
    @additional_css_classes = additional_css_classes
    @open = open ? 'open' : nil
  end

  def css_classes
    @additional_css_classes.nil? ? 'govuk-details' : 'govuk-details ' + @additional_css_classes
  end
end

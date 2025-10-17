class SummaryCardHeaderComponent < ViewComponent::Base
  def initialize(title:, heading_level: 2, anchor: nil, title_contains_pii: false)
    @title = title
    @heading_level = heading_level
    @anchor = anchor
    @title_contains_pii = title_contains_pii
  end

  def attributes
    [].tap do |html_attributes|
      html_attributes << @anchor.to_s if @anchor.present?
      html_attributes << 'data-clarity-mask=True' if @title_contains_pii
    end.join(' ')
  end
end

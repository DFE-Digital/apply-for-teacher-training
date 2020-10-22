class GovUkStartButtonComponent < ViewComponent::Base
  attr_accessor :title, :href

  def initialize(title:, href:)
    self.title = title
    self.href = href
  end
end

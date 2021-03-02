class DfEComponent::PrimaryNavigation::Component < ViewComponent::Base
  include ViewHelper
  attr_reader :items

  def initialize(items:)
    @items = items
  end
end

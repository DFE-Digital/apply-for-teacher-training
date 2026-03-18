class PrimaryNavigationComponent < ApplicationComponent
  include ViewHelper

  attr_reader :items

  def initialize(items:, items_right: [])
    @items = items
    @items_right = items_right
  end
end

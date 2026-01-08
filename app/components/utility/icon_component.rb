class IconComponent < BaseComponent
  include ViewHelper

  attr_reader :type

  def initialize(type:)
    @type = type
  end
end

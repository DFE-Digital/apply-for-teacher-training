class IconComponent < ApplicationComponent
  include ViewHelper

  attr_reader :type

  def initialize(type:)
    @type = type
  end
end

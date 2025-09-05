class SandboxFeatureComponent < ApplicationComponent
  attr_accessor :description

  def initialize(description:)
    @description = description
  end
end

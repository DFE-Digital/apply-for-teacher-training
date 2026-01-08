class SandboxFeatureComponent < BaseComponent
  attr_accessor :description

  def initialize(description:)
    @description = description
  end
end

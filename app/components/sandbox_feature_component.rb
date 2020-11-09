class SandboxFeatureComponent < ViewComponent::Base
  attr_accessor :description

  def initialize(description:)
    @description = description
  end
end

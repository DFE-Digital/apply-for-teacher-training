class PhaseBanner < ViewComponent::Base
  def initialize(stacked: false)
    @stacked = stacked
  end
end

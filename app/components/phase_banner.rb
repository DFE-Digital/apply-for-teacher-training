class PhaseBanner < ViewComponent::Base
  def initialize(no_border: false)
    @no_border = no_border
  end
end

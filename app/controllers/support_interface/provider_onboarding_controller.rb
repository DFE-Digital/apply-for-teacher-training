module SupportInterface
  class ProviderOnboardingController < SupportInterface::SupportInterfaceController
    def index
      @monitor = SupportInterface::ProviderOnboardingMonitor.new
    end
  end
end

module SupportInterface
  class ProviderOnboardingController < SupportInterface::SupportInterfaceController
    def index
      authorize(nil, :show?, policy_class: SupportInterface::ProviderPolicy)

      @monitor = SupportInterface::ProviderOnboardingMonitor.new
    end
  end
end

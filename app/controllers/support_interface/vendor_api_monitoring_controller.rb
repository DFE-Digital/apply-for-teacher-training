module SupportInterface
  class VendorAPIMonitoringController < SupportInterface::SupportInterfaceController
    def index
      @monitor = SupportInterface::VendorAPIMonitor.new
    end
  end
end

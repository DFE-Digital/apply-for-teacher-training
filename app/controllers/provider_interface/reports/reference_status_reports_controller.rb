module ProviderInterface
  module Reports
    class ReferenceStatusReportsController < ProviderInterfaceController
      attr_reader :provider

      def show
        @provider = current_user.providers.find(provider_id)
        @report = ProviderInterface::ReferenceStatusReport.new(@provider)

        @rows = @report.rows
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end

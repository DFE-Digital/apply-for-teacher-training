module APIDocs
  module VendorAPIDocs
    class OpenapiController < APIDocsController
      before_action only: [:spec_draft], unless: -> { FeatureFlag.active?(:draft_vendor_api_specification) } do
        redirect_to api_docs_spec_path
      end

      def spec_draft
        spec(draft: true)
      end

      def spec_current
        spec(version: AllowedCrossNamespaceUsage::VendorAPIInfo.released_version)
      end

      def spec_1_0
        spec(version: VendorAPI::VERSION_1_0)
      end

      def spec_1_1
        spec(version: VendorAPI::VERSION_1_1)
      end

      def spec_1_2
        spec(version: VendorAPI::VERSION_1_2)
      end

      def spec_1_3
        spec(version: VendorAPI::VERSION_1_3)
      end

      def spec_1_4
        spec(version: VendorAPI::VERSION_1_4)
      end

      def spec_1_5
        spec(version: VendorAPI::VERSION_1_5)
      end

      def spec_1_6
        spec(version: VendorAPI::VERSION_1_6)
      end

      def spec_1_7
        spec(version: VendorAPI::VERSION_1_7)
      end

    private

      def spec(**)
        render plain: VendorAPISpecification.new(**).as_yaml, content_type: 'text/yaml'
      end
    end
  end
end

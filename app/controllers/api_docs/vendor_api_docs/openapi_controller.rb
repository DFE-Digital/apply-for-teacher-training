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
        spec(version: VendorAPI::VERSION)
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

    private

      def spec(**options)
        render plain: VendorAPISpecification.new(**options).as_yaml, content_type: 'text/yaml'
      end
    end
  end
end

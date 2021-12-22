module APIDocs
  module VendorAPIDocs
    class OpenapiController < APIDocsController
      include VersioningHelpers

      def current_spec
        spec_1_0
      end

      def spec_1_0
        render plain: VendorAPISpecification.new(version: '1.0').as_yaml, content_type: 'text/yaml'
      end

      def spec_1_1
        return redirect_to api_docs_spec_1_0_path unless FeatureFlag.active?(:draft_vendor_api_specification)

        render plain: VendorAPISpecification.new(version: '1.1').as_yaml, content_type: 'text/yaml'
      end

      def spec
        render plain: VendorAPISpecification.new(version: api_version).as_yaml, content_type: 'text/yaml'
      end

      def api_version
        return VendorAPISpecification::CURRENT_VERSION unless params.key?(:api_version)

        extract_version(params[:api_version])
      end
    end
  end
end

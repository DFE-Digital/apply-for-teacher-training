module APIDocs
  module VendorAPIDocs
    class OpenapiController < APIDocsController
      def current_spec
        spec_1_0
      end

      def spec_1_0
        render plain: VendorAPISpecification.new(version: '1.0').as_yaml, content_type: 'text/yaml'
      end

      def spec_1_1
        render plain: VendorAPISpecification.new(version: '1.1').as_yaml, content_type: 'text/yaml'
      end
    end
  end
end

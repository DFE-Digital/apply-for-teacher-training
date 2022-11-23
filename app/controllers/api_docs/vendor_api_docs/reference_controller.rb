module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      include VersioningHelpers

      def reference
        return redirect_to(api_docs_production_version_reference_path, status: :moved_permanently) if api_version_param.nil?

        @api_reference = APIReference.new(VendorAPISpecification.new(version:).as_hash, version:)
      end

      def draft
        return redirect_to api_docs_reference_path unless FeatureFlag.active?(:draft_vendor_api_specification)

        @api_reference = APIReference.new(VendorAPISpecification.new(draft: true).as_hash, draft: true)
      end

    private

      def version
        extract_version(api_version_param)
      end
      helper_method :version

      def api_version_param
        params[:api_version]
      end

      def api_docs_production_version_reference_path
        api_docs_versioned_reference_path("v#{AllowedCrossNamespaceUsage::VendorAPIInfo.production_version}")
      end

      def spec_url_for_current_version
        case version
        when '1.0'
          api_docs_spec_1_0_url
        when '1.1'
          api_docs_spec_1_1_url
        when '1.2'
          api_docs_spec_1_2_url
        end
      end
      helper_method :spec_url_for_current_version
    end
  end
end

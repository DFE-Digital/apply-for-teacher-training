module VendorAPI
  class MultipleApplicationsPresenter < Base
    attr_reader :applications, :options, :request, :include_incomplete_references

    def initialize(version, applications, request = {}, options = {}, include_incomplete_references: false)
      super(version)
      @applications = applications
      @request = request
      @options = options
      @include_incomplete_references = include_incomplete_references
    end

    def serialized_applications_data
      %({"data":[#{serialized_applications.join(',')}]})
    end

    def serialized_applications
      applications_scope.map do |application|
        ApplicationPresenter.new(
          active_version,
          application,
          include_incomplete_references:,
        ).serialized_json
      end
    end

    def applications_scope
      applications
        .find_each(batch_size: 500)
        .sort_by(&:updated_at)
        .reverse
    end
  end
end

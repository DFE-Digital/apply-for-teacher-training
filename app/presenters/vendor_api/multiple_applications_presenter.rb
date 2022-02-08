module VendorAPI
  class MultipleApplicationsPresenter < Base
    attr_reader :applications, :options, :request

    def initialize(version, applications, request = {}, options = {})
      super(version)
      @applications = applications
      @request = request
      @options = options
    end

    def serialized_applications_data
      %({"data":[#{serialized_applications.join(',')}]})
    end

    def serialized_applications
      applications_scope.map do |application|
        ApplicationPresenter.new(active_version, application).serialized_json
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

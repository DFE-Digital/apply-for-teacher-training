module VendorAPI
  class MultipleApplicationsPresenter < Base
    attr_reader :applications, :options

    def initialize(version, applications, options)
      super(version)
      @applications = applications
      @options = options
    end

    def serialized_applications_data
      %({"data":[#{serialized_applications.join(',')}]})
    end

    def serialized_applications
      applications.map do |application|
        ApplicationPresenter.new(active_version, application).serialized_json
      end
    end
  end
end

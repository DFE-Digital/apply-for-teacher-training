module VendorAPI
  class SingleApplicationPresenter < Base
    attr_reader :application

    def initialize(version, application)
      super(version)
      @application = application
    end

    def serialized_json
      serialized_application_json = ApplicationPresenter.new(
        active_version,
        application,
      ).serialized_json

      %({"data":#{serialized_application_json}})
    end
  end
end

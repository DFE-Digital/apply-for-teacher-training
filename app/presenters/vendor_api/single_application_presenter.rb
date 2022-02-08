module VendorAPI
  class SingleApplicationPresenter < Base
    attr_reader :application

    def initialize(version, application)
      super(version)
      @application = application
    end

    def serialized_json
      %({"data":#{ApplicationPresenter.new(active_version, application).serialized_json}})
    end
  end
end

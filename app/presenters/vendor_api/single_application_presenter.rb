module VendorAPI
  class SingleApplicationPresenter < Base
    attr_reader :application, :include_incomplete_references

    def initialize(version, application, include_incomplete_references: false)
      super(version)
      @application = application
      @include_incomplete_references = include_incomplete_references
    end

    def serialized_json
      references = ApplicationPresenter.new(
        active_version,
        application,
        include_incomplete_references: include_incomplete_references,
      ).serialized_json

      %({"data":#{references}})
    end
  end
end

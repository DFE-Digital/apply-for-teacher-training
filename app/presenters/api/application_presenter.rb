module API
  class ApplicationPresenter < Base
    VERSION = '1.1'

    VERSIONS = {
      '1.2' => ['MoreApplicationData'],
      '1.3' => ['AddCourseToApplication'],
    }

    attr_reader :application_choice, :version

    def initialize(version, applications)
      super(version)
      @version = version
      @application_choice = applications.first
    end

    def json
      schema.to_json
    end

    def schema
      {
        version: version,
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          application_url: provider_interface_application_choice_url(application_choice),
        }
      }
    end
  end
end

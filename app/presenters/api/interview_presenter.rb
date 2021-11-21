module API
  class InterviewPresenter < Base
    VERSION = '1.2'

    VERSIONS = {
    }

    attr_reader :interview, :version

    def initialize(version, interviews)
      super(version)
      @version = version
      @interview = interviews.first
    end

    def json
      schema.to_json
    end

    def schema
      {
        version: version,
        id: interview.id.to_s,
        type: 'interview',
        attributes: {
          interview_url: provider_interface_application_choice_interview_url(interview.application_choice, interview),
        }
      }
    end
  end
end

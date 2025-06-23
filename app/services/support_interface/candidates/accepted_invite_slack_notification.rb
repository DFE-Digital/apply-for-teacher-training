module SupportInterface
  class Candidates::AcceptedInviteSlackNotification
    include Rails.application.routes.url_helpers
    attr_reader :invite, :application_form

    def initialize(invite:, application_form:)
      @invite = invite
      @application_form = application_form
    end

    def self.call(invite:, application_form:)
      new(invite:, application_form:).call
    end

    def call
      SlackNotificationWorker.perform_async(
        message,
        nil,
        '#sd_find_a_candidate_2025',
        ENV['FIND_AND_APPLY_SLACK_URL'],
      )
    end

  private

    def message
      <<~MARKDOWN
        Candidate ID <#{support_interface_application_form_url(application_form)}|#{application_form.candidate_id}> \
        has just been recruited following an invitation from \
        <#{support_interface_provider_url(invite.provider)}|#{invite.provider.name}> \
        to <#{support_interface_course_url(invite.course)}|#{invite.course.name}> :clapclap-e:
      MARKDOWN
    end
  end
end

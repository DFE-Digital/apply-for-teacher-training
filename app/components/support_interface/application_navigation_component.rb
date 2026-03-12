module SupportInterface
  class ApplicationNavigationComponent < ApplicationComponent
    include ViewHelper

    def initialize(application_form)
      @application_form = application_form
    end

    def links
      [
        email_log_link,
        sentry_link,
      ]
    end

  private

    def email_log_link
      {
        title: 'Emails about this application',
        href: support_interface_email_log_path(application_form_id: @application_form.id),
      }
    end

    def sentry_link
      link = "https://dfe-teacher-services.sentry.io/issues/?project=1765973&query=user.id%3A%22candidate_#{@application_form.candidate_id}%22&statsPeriod=90d"

      {
        title: 'Sentry errors for this candidate',
        href: link,
      }
    end
  end
end

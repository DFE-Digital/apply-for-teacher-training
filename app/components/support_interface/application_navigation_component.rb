module SupportInterface
  class ApplicationNavigationComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form)
      @application_form = application_form
    end

    def links
      [
        email_log_link,
        logit_link,
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
      link = "https://sentry.io/organizations/dfe-bat/issues/?project=1765973&query=user.id%3A%22candidate_#{@application_form.candidate_id}%22"

      {
        title: 'Sentry errors for this candidate',
        href: link,
      }
    end

    def logit_link
      link = "https://kibana.logit.io/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15d,to:now))&_a=(columns:!(_source),filters:!(),index:'8ac115c0-aac1-11e8-88ea-0383c11b333c',interval:auto,query:(language:kuery,query:'application:%22#{current_logit_application_name}%22%20AND%20payload.candidate_id:#{@application_form.candidate_id}'),sort:!('@timestamp',desc))"

      {
        title: 'Logit logs for this candidate',
        href: link,
      }
    end

    def current_logit_application_name
      if HostingEnvironment.environment_name == 'production' && HostingEnvironment.sandbox_mode?
        'apply-sandbox'
      elsif HostingEnvironment.production?
        'apply-prod'
      else
        {
          'staging' => 'apply-staging',
          'qa' => 'apply-qa',
        }[HostingEnvironment.environment_name]
      end
    end
  end
end

module SupportInterface
  class DocsController < SupportInterfaceController
    def index; end

    def provider_flow; end

    def candidate_flow; end

    def when_emails_are_sent; end

    def qualifications; end

    def mailer_previews
      @previews = ActionMailer::Preview.all
      @page_title = 'Mailer Previews'
    end
  end
end

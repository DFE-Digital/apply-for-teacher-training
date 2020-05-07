module SupportInterface
  class MailerPreviewsController < SupportInterfaceController
    def index
      @previews = ActionMailer::Preview.all
      @page_title = 'Mailer Previews'
    end
  end
end

module SupportInterface
  class EmailLogController < SupportInterfaceController
    def index
      @emails = Email.order(id: :desc).includes(:application_form).limit(1000)

      %w[to subject mailer mail_template notify_reference application_form_id delivery_status].each do |column|
        next unless params[column]

        @emails = @emails.where(column => params[column])
      end
    end
  end
end

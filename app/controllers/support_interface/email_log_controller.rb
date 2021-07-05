module SupportInterface
  class EmailLogController < SupportInterfaceController
    def index
      @filter = SupportInterface::EmailsFilter.new(params: params)

      @emails = Email
        .order(id: :desc)
        .includes(:application_form)
        .page(params[:page] || 1).per(30)

      if params[:q]
        @emails = @emails.where("CONCAT(\"to\", ' ', subject, ' ', notify_reference, ' ', body) ILIKE ?", "%#{params[:q]}%")
      end

      if params[:delivery_status]
        @emails = @emails.where(delivery_status: params[:delivery_status])
      end

      if params[:mailer]
        @emails = @emails.where(mailer: params[:mailer])
      end

      %w[to subject mail_template notify_reference application_form_id].each do |column|
        next unless params[column]

        @emails = @emails.where(column => params[column])
      end
    end
  end
end

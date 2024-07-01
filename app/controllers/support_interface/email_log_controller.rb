module SupportInterface
  class EmailLogController < SupportInterfaceController
    def index
      @filter = SupportInterface::EmailsFilter.new(params:)

      emails = Email
        .order(id: :desc)
        .includes(:application_form)
        .where('created_at >= ?', @filter.applied_filters[:created_since])

      if @filter.applied_filters[:q].present?
        emails = emails.where("CONCAT(\"to\", ' ', subject, ' ', notify_reference, ' ', body) ILIKE ?", "%#{@filter.applied_filters[:q]}%")
      end

      if @filter.applied_filters[:delivery_status].present?
        emails = emails.where(delivery_status: @filter.applied_filters[:delivery_status])
      end

      if @filter.applied_filters[:mailer].present?
        emails = emails.where(mailer: @filter.applied_filters[:mailer])
      end

      %w[to subject mail_template notify_reference application_form_id].each do |column|
        next if @filter.applied_filters[column].blank?

        emails = emails.where(column => @filter.applied_filters[column])
      end

      @pagy, @emails = pagy(emails, page: params[:page], items: 30)
    end
  end
end

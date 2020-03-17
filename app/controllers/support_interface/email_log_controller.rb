module SupportInterface
  class EmailLogController < SupportInterfaceController
    def index
      @emails = Email.order(id: :desc).includes(:application_form).limit(1000)
    end
  end
end

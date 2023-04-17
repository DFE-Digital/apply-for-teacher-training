module SupportInterface
  module ApplicationForms
    class DeleteApplicationForm
      include ActiveModel::Model

      attr_accessor :application_form, :accept_guidance, :audit_comment_ticket

      validates :accept_guidance, presence: true
      validates :audit_comment_ticket, presence: true
      validates_with ZendeskUrlValidator

      def save(actor:, application_form:)
        @application_form = application_form

        return false unless valid?

        DeleteApplication.new(
          actor:,
          application_form:,
          zendesk_url: audit_comment_ticket,
        ).call!
      end

      def application_form_id
        @application_form.id
      end
    end
  end
end

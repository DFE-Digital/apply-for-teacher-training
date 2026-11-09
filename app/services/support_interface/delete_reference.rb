module SupportInterface
  class DeleteReference
    include ImpersonationAuditHelper

    def call!(actor:, reference:, zendesk_url: audit_comment_ticket)
      audit(actor) do
        ApplicationForm.with_unsafe_application_choice_touches do
          ActiveRecord::Base.transaction do
            reference.audit_comment = "Data deletion request: #{zendesk_url}"
            reference.destroy!
          end
        end
      end
    end
  end
end

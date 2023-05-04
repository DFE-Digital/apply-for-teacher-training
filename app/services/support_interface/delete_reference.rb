module SupportInterface
  class DeleteReference
    include ImpersonationAuditHelper

    def call!(actor:, reference:, zendesk_url: audit_comment_ticket)
      audit(actor) do
        ActiveRecord::Base.transaction do
          reference.audit_comment = "Data deletion request: #{zendesk_url}"
          reference.destroy!
        end
      end
    end
  end
end

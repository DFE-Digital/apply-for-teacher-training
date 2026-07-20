module SupportInterface
  class NotifySendRequest < ApplicationRecord
    belongs_to :support_user

    validates :template_id, presence: true
    validates :email_addresses, presence: true

    has_one_attached :file

    def send_emails
      Support::SendNotifyTemplateWithAttachmentWorker.perform_async(id)
    end
  end
end

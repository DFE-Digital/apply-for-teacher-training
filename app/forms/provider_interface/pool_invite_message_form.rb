module ProviderInterface
  class PoolInviteMessageForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :invite
    attribute :provider_message, :boolean
    attribute :message_content, :string
    attribute :remember, :boolean
    attribute :return_to, :string

    validates :provider_message, inclusion: { in: [true, false] }
    validates :message_content, presence: true, if: -> { provider_message == true }
    validates :message_content, word_count: { maximum: 200 }, if: -> { provider_message == true }

    delegate :persisted?, to: :invite

    def save
      ActiveRecord::Base.transaction do
        invite.update!(
          provider_message:,
          message_content: provider_message == true ? message_content : nil,
        )

        if remember && provider_message
          template = invite.invited_by.provider_user_content_templates.create!(
            body: message_content,
            in_use: true,
          )
          invite.invited_by.provider_user_content_templates.invite_message
            .where(in_use: true)
            .where.not(id: template.id).delete_all
        elsif provider_message
          invite.invited_by.provider_user_content_templates.delete_all
        end
      end

      invite
    end
  end
end

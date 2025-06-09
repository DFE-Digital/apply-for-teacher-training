module ProviderInterface
  class PoolInviteMessageForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :invite
    attribute :provider_message, :boolean
    attribute :message_content, :string
    attribute :return_to, :string

    validates :provider_message, inclusion: { in: [true, false] }
    validates :message_content, presence: true, if: -> { provider_message == true }
    validates :message_content, word_count: { maximum: 200 }, if: -> { provider_message == true }

    delegate :persisted?, to: :invite

    def save
      invite.update!(
        provider_message:,
        message_content: provider_message == true ? message_content : nil,
      )
      invite
    end
  end
end

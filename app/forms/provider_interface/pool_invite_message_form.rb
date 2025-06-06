module ProviderInterface
  class PoolInviteMessageForm
    include ActiveModel::Model

    attr_accessor :provider_message, :message_content
    attr_reader :invite

    validates :provider_message, presence: true
    validates :message_content, presence: true, if: -> { provider_message == 'true' }
    validates :message_content, word_count: { maximum: 200 }, if: -> { provider_message == 'true' }

    def initialize(invite: nil, invite_message_params: {})
      @invite = invite
      super(invite_message_params)
    end

    def save
      invite.update!(
        provider_message:,
        message_content: provider_message == 'false' ? nil : message_content,
      )
      invite
    end
  end
end

module ProviderInterface
  class PoolInviteMessageForm
    include ActiveModel::Model

    attr_accessor :invite_message, :message
    attr_reader :invite

    validates :invite_message, presence: true
    validates :message, presence: true, if: -> { invite_message == 'true' }
    validates :message, word_count: { maximum: 200 }, if: -> { invite_message == 'true' }

    def initialize(invite: nil, invite_message_params: {})
      @invite = invite
      super(invite_message_params)
    end

    def save
      invite.update!(
        invite_message:,
        message: invite_message == 'false' ? nil : message,
      )
      invite
    end
  end
end

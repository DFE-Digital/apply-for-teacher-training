class ProviderUserContentTemplate < ApplicationRecord
  belongs_to :provider_user

  enum :kind, {
    invite_message: 'invite_message',
  }
end

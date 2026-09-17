class ProviderUserContentTemplate < ApplicationRecord
  belongs_to :provider_user
  # in_use boolean is meant to be used if we allow users to set their own templates

  enum :kind, {
    invite_message: 'invite_message',
  }
end

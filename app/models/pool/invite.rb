class Pool::Invite < ApplicationRecord
  belongs_to :candidate
  belongs_to :provider
  belongs_to :invited_by, class_name: 'ProviderUser'
  belongs_to :course

  enum :status, {
    draft: 'draft',
    published: 'published',
  }
end

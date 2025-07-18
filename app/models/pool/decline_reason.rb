class Pool::DeclineReason < ApplicationRecord
  belongs_to :invite, class_name: 'Pool::Invite'

  enum :status, {
    draft: 'draft',
    published: 'published',
  }, default: :draft
end

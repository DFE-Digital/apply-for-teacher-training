class ServiceBanner < ApplicationRecord
  enum :status, {
    draft: 'draft',
    published: 'published',
    used: 'used',
  }, default: :draft
end

class ServiceBanner < ApplicationRecord
  enum :status, {
    draft: 'draft',
    published: 'published',
  }, default: :draft
end

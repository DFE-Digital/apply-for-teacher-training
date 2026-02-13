class ServiceBanner < ApplicationRecord
  enum :status, {
    draft: 'draft',
    published: 'published',
    unpublished: 'unpublished',
  }, default: :draft
end

class ServiceBanner < ApplicationRecord
  audited

  enum :status, {
    draft: 'draft',
    published: 'published',
    used: 'used',
  }, default: :draft
end

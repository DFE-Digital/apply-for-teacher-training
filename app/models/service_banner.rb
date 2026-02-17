class ServiceBanner < ApplicationRecord
  audited if: :audit_enabled?

  enum :status, {
    draft: 'draft',
    published: 'published',
    used: 'used',
  }, default: :draft

private

  def audit_enabled?
    status != 'draft'
  end
end

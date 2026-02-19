class ServiceBanner < ApplicationRecord
  audited if: :audit_enabled?

  enum :status, {
    draft: 'draft',
    published: 'published',
    used: 'used',
  }, default: :draft

  enum :interface, {
    apply: 'apply',
    manage: 'manage',
    support_console: 'support_console',
  }

private

  def audit_enabled?
    status != 'draft'
  end
end

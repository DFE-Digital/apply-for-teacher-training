module SupportInterface
  class AuditTrailItemComponent < ActionView::Component::Base
    include ViewHelper

    validates :audit, presence: true

    def initialize(audit:)
      @audit = audit
    end

    def audit_entry_event_label
      if audit.comment.present? && audit.audited_changes.empty?
        "Comment on #{audit.auditable_type.titlecase}"
      else
        "#{audit.action.capitalize} #{audit.auditable_type.titlecase} ##{audit.auditable_id}"
      end
    end

    def audit_entry_user_label
      if audit.user_type == 'Candidate'
        "#{audit.user.email_address} (Candidate)"
      elsif audit.user_type == 'VendorApiUser'
        "#{audit.user.email_address} (Vendor API)"
      elsif audit.user_type == 'SupportUser'
        "#{audit.user.email_address} (Support user)"
      elsif audit.username.present?
        audit.username
      else
        '(Unknown User)'
      end
    end

    def changes
      audit.audited_changes.merge(comment_change).select { |_, values| audit_value_present?(values) }
    end

    def comment_change
      { 'comment' => audit.comment }
    end

    def audit_value_present?(value)
      if value.is_a? Array
        value.any?(&:present?)
      else
        value.present?
      end
    end

    attr_reader :audit
  end
end

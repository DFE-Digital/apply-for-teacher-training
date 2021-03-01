module SupportInterface
  class FeatureAuditTrailComponent < ViewComponent::Base
    include ViewHelper

    ACTIVE_LABEL = 'Active'.freeze
    INACTIVE_LABEL = 'Inactive'.freeze

    def initialize(feature:)
      @feature = feature
    end

    def user_label_for(audit)
      if audit.user_type == 'SupportUser'
        " by #{audit.user.email_address}"
      elsif audit.username.present?
        " by #{audit.username}"
      end
    end

    def action_label_for(audit)
      audit.action == 'create' ? 'Created' : 'Changed to'
    end

    def active_value_for(audit)
      active_change = audit.audited_changes['active']
      return INACTIVE_LABEL if active_change.blank?

      is_active =
        if active_change.is_a?(Array)
          active_change.second
        else
          active_change
        end

      is_active ? ACTIVE_LABEL : INACTIVE_LABEL
    end

    def visible?(audit)
      audit.action == 'create' || !audit.audited_changes['active'].nil?
    end

    attr_reader :feature
    delegate :audits, to: :feature
  end
end

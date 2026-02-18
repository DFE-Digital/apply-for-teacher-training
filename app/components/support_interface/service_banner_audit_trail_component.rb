module SupportInterface
  class ServiceBannerAuditTrailComponent < ViewComponent::Base
    def initialize(interface: nil, banner_id: nil)
      @interface = interface
      @banner_id = banner_id
    end

    def audits
      if @banner_id
        Audited::Audit.where(auditable_type: 'ServiceBanner', auditable_id: @banner_id)
          .order(created_at: :desc)
      else
        Audited::Audit.where(auditable_type: 'ServiceBanner', auditable_id: previous_banners.pluck(:id))
          .order(created_at: :desc)
          .limit(4)
      end
    end

    def previous_banners
      ServiceBanner.where(interface: @interface)
    end

    def user_label_for(audit)
      if audit.user_type == 'SupportUser'
        audit.user.email_address
      elsif audit.username.present?
        audit.username
      end
    end

    def action_label_for(audit)
      if audit.audited_changes['status']&.include?('used')
        'disabled'
      else
        'enabled'
      end
    end
  end
end

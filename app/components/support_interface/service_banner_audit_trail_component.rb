module SupportInterface
  class ServiceBannerAuditTrailComponent < ViewComponent::Base
    def initialize(interface: nil, banner_id: nil)
      @interface = interface
      @banner_id = banner_id
    end

    def audits
      scope = Audited::Audit
        .where(auditable_type: 'ServiceBanner', auditable_id: banner_ids)
        .order(created_at: :desc)

      @banner_id ? scope : scope.limit(4)
    end

    def audit_list_items
      audits.map do |audit|
        content = banner_link_or_text(audit)
        safe_join([
          content,
          tag.br,
          tag.span(timestamp_hint(audit), class: 'govuk-hint govuk-!-margin-bottom-0 govuk-!-font-size-16'),
        ])
      end
    end

  private

    def banner_ids
      @banner_id || previous_banners.ids
    end

    def previous_banners
      ServiceBanner.where(interface: @interface)
    end

    def banner_link_or_text(audit)
      text = "Banner #{action_label_for(audit)} by #{user_label_for(audit)} "

      return tag.span(text) if @banner_id

      govuk_link_to(
        text,
        support_interface_show_show_service_banner_path(audit.auditable_id),
      )
    end

    def timestamp_hint(audit)
      "#{l(audit.created_at.to_date, format: :long)} at #{l(audit.created_at, format: :time)}"
    end

    def user_label_for(audit)
      return audit.user.email_address if audit.user_type == 'SupportUser'

      audit.username.presence
    end

    def action_label_for(audit)
      audit.audited_changes['status']&.include?('used') ? 'disabled' : 'enabled'
    end
  end
end

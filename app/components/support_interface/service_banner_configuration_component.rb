module SupportInterface
  class ServiceBannerConfigurationComponent < ViewComponent::Base
    attr_reader :interface

    def initialize(interface:)
      @interface = interface
    end

    def rows
      [
        show_service_banner_row,
        banner_content_row,
        history_row,
      ].compact
    end

  private

    def show_service_banner_row
      {
        key: 'Show service banner',
        value: live_banner ? 'Yes' : 'No',
        action: {
          href: support_interface_edit_show_service_banner_path(interface: @interface),
          visually_hidden_text: 'Change',
        },
      }
    end

    def banner_content_row
      return unless live_banner

      {
        key: 'Banner content',
        value: t('.live_banner_html', header: live_banner.header, body: live_banner.body),
        action: {
          href: support_interface_edit_configure_service_banner_path(live_banner, interface: @interface),
          visually_hidden_text: 'Change',
        },
      }
    end

    def history_row
      {
        key: 'History',
        value: audit_text,
      }
    end

    def audit_text
      return '-' unless recent_audits.any?

      tag.ul(class: %w[govuk-list govuk-list--bullet]) do
        safe_join(
          recent_audits.map do |audit|
            tag.li do
              safe_join([
                govuk_link_to("Banner #{action_label_for(audit)} by #{user_label_for(audit)} ", support_interface_show_show_service_banner_path(ServiceBanner.find(audit.auditable_id))),
                tag.span(class: %w[govuk-hint govuk-!-margin-bottom-0 govuk-!-font-size-16]) do
                  "#{audit.created_at.to_date.to_fs(:long)} at #{audit.created_at.to_fs(:time)}"
                end,
              ])
            end
          end,
        )
      end
    end

    def recent_audits
      Audited::Audit.where(auditable_type: 'ServiceBanner', auditable_id: previous_banners.pluck(:id))
          .order(created_at: :desc)
          .limit(4)
    end

    def previous_banners
      ServiceBanner.where(interface: @interface.downcase.tr('_', ' '))
    end

    def user_label_for(audit)
      if audit.user_type == 'SupportUser'
        audit.user.email_address
      elsif audit.username.present?
        audit.username
      end
    end

    def action_label_for(audit)
      if audit.audited_changes['status'].include?('used')
        'disabled'
      elsif ['draft', %w[published draft]].include?(audit.audited_changes['status'])
        'drafted'
      elsif audit.audited_changes['status'] == %w[draft published]
        'enabled'
      end
    end

    def live_banner
      ServiceBanner.where(interface: @interface.downcase.tr('_', ' '), status: 'published').order(created_at: :desc).first
    end
  end
end

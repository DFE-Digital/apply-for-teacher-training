module ProviderInterface
  class APITokenSummaryComponent < ApplicationComponent
    include Rails.application.routes.url_helpers

    attr_reader :token, :can_manage_tokens, :view, :path_to_revoke, :interface

    def initialize(token:, can_manage_tokens:, path_to_revoke: nil, view: 'show', interface: 'provider')
      @token = token
      @can_manage_tokens = can_manage_tokens
      @view = view
      @path_to_revoke = path_to_revoke
      @interface = interface
    end

    def items
      case view
      when 'show'
        {
          t('.created_by') => created_by,
          t('.created_at') => created_at,
          t('.token_for') => token.vendor_name,
          t('.last_used_on') => last_used_at,
          t('.status') => {
            field_value: token.status.capitalize,
            action: revoke_token,
          },
        }
      when 'confirm_revoke'
        {
          t('.name') => token.name,
          t('.created_by') => created_by,
          t('.created_at') => created_at,
          t('.token_for') => token.vendor_name,
          t('.last_used_on') => last_used_at,
        }
      when 'revoked'
        {
          t('.created_by') => created_by,
          t('.created_at') => created_at,
          t('.token_for') => token.vendor_name,
          t('.last_used_on') => last_used_at,
          t('.status') => {
            field_value: token.status.capitalize,
            action: revoke_token,
          },
          t('.revoked_at') => token.discarded_at&.to_fs(:govuk_date_and_time),
          t('.revoked_by') => discarded_by,
        }
      end
    end

    def revoke_token
      if can_manage_tokens && token.undiscarded?
        {
          text: t('.revoke'),
          href: path_to_revoke,
          classes: ['app-link--warning'],
          visually_hidden_text: t('.token'),
        }
      end
    end

    def created_by
      created_audit = token.audits.find_by(action: 'create')
      return t('.default_user') if created_audit.blank?

      if created_audit.user.present? && created_audit.user_type == 'ProviderUser'
        created_audit.user.full_name
      else
        t('.default_user')
      end
    end

    def last_used_at
      token.last_used_at&.to_fs(:govuk_date_and_time) || t('.not_used')
    end

    def created_at
      token.created_at.to_fs(:govuk_date_and_time)
    end

    def discarded_by
      discarded_audit = token.audits
        .where(action: 'update')
        .where("audited_changes ? 'discarded_at'").first

      return t('.default_user') if discarded_audit.blank?

      revoked_by_provider_user = discarded_audit.user.present? && discarded_audit.user_type == 'ProviderUser'
      revoked_by_support_user = discarded_audit.user.present? && discarded_audit.user_type == 'SupportUser' && interface == 'support'

      if revoked_by_provider_user || revoked_by_support_user
        discarded_audit.user.display_name
      else
        t('.default_user')
      end
    end
  end
end

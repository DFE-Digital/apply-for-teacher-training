module ProviderInterface
  class APITokensTableComponent < ApplicationComponent
    include Rails.application.routes.url_helpers

    attr_reader :api_tokens

    def initialize(api_tokens:)
      @api_tokens = api_tokens
    end

    def head
      [
        t('.description'),
        t('.created_by'),
        t('.created_at'),
        t('.last_used_at'),
      ]
    end

    def rows
      api_tokens.map do |token|
        [
          description_cell(token),
          created_by_cell(token),
          created_at_cell(token),
          last_used_at_cell(token),
        ]
      end
    end

    def last_used_at_cell(token)
      token.last_used_at&.to_fs(:govuk_date_and_time) || t('.not_used')
    end

    def created_at_cell(token)
      token.created_at.to_fs(:govuk_date_and_time)
    end

    def created_by_cell(token)
      created_audit = token.audits.find_by(action: 'create')
      return t('.default_user') if created_audit.blank?

      if created_audit.user.present? && created_audit.user_type == 'ProviderUser'
        created_audit.user.full_name
      else
        t('.default_user')
      end
    end

    def description_cell(token)
      description = token.description.presence || t('.no_description') # are there tokens without description?
      govuk_link_to(description.to_s, provider_interface_organisation_settings_organisation_api_token_path(token.provider_id, token.id))
    end

    def call
      govuk_table(head:, rows:) do |table|
        table.with_caption(text: t('.caption'), html_attributes: { class: 'govuk-visually-hidden' })
      end
    end
  end
end

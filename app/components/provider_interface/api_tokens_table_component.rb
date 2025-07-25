module ProviderInterface
  class APITokensTableComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers

    attr_reader :api_tokens, :can_manage_tokens

    def initialize(api_tokens:)
      @api_tokens = api_tokens
    end

    def head
      [
        t('.id'),
        t('.last_used_at'),
        t('.created_at'),
        t('.created_by'),
      ]
    end

    def rows
      api_tokens.map do |token|
        [
          token.id.to_s,
          last_used_at_cell(token),
          created_at_cell(token),
          created_by_cell(token),
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

      if created_audit.user.present? && created_audit.user_type == 'ProviderUser'
        created_audit.user.email_address
      else
        t('.default_user')
      end
    end

    def call
      govuk_table(head:, rows:) do |table|
        table.with_caption(text: t('.caption'), html_attributes: { class: 'govuk-visually-hidden' })
      end
    end
  end
end

module SupportInterface
  class VendorAPITokenFilter
    include FilterParamsHelper

    RECENT = 'recent'.freeze
    NOT_RECENT = 'not_recent'.freeze
    REVOKED = 'revoked'.freeze

    attr_reader :applied_filters

    def initialize(filter_params:)
      @applied_filters = compact_params(filter_params)
    end

    def filtered_tokens
      scope = tokens
      scope = providers(scope)
      scope = token_name(scope)
      scope = used_recently(scope)
      scope = vendors_condition(scope)
      scope.order(
        VendorAPIToken.arel_table[:last_used_at].desc.nulls_last,
        created_at: :desc,
      )
    end

    def filters
      [
        {
          type: :search,
          heading: 'Provider name or code',
          name: 'provider_name_or_code',
          value: applied_filters[:provider_name_or_code],
        },
        {
          type: :search,
          heading: 'Token name',
          name: 'token_name',
          value: applied_filters[:token_name],
        },
        {
          type: :checkboxes,
          heading: 'Vendors',
          name: 'vendor_ids',
          options: Vendor.all.map do |vendor|
            {
              value: vendor.id,
              label: vendor.name.humanize,
              checked: applied_filters[:vendor_ids]&.include?(vendor.id.to_s),
            }
          end,
        },
        {
          type: :checkboxes,
          heading: 'Activity',
          name: 'activity',
          options: [
            { value: 'recent', label: 'Used within 60 days', checked: applied_filters[:activity]&.include?(RECENT) },
            { value: 'not_recent', label: 'Not used for 60 days', checked: applied_filters[:activity]&.include?(NOT_RECENT) },
          ],
        },
      ]
    end

    def hidden_filters
      [
        {
          type: :hidden,
          name: 'filter_tab',
          value: REVOKED,
        },
      ]
    end

  private

    def tokens
      return VendorAPIToken.discarded if applied_filters[:filter_tab] == REVOKED

      VendorAPIToken.undiscarded
    end

    def providers(scope)
      return scope if applied_filters[:provider_name_or_code].blank?

      scope.left_joins(:provider)
       .where("CONCAT(providers.name, ' ', providers.code) ILIKE ?", "%#{applied_filters[:provider_name_or_code]}%")
    end

    def token_name(scope)
      return scope if applied_filters[:token_name].blank?

      scope.where('description ILIKE ?', "%#{applied_filters[:token_name]}%")
    end

    def vendors_condition(scope)
      return scope if applied_filters[:vendor_ids].blank?

      scope.left_joins(:provider)
        .where(providers: { vendor_id: applied_filters[:vendor_ids] })
    end

    def used_recently(scope)
      if applied_filters[:activity] == [RECENT]
        scope.used_in_last_60_days
      elsif applied_filters[:activity] == [NOT_RECENT]
        scope.stale
      else
        scope
      end
    end
  end
end

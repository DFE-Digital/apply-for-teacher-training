module SupportInterface
  class VendorAPITokenFilter
    include FilterParamsHelper

    attr_reader :applied_filters

    def initialize(filter_params:)
      @applied_filters = compact_params(filter_params)
    end

    def filtered_tokens
      scope = VendorAPIToken.order(
        VendorAPIToken.arel_table[:last_used_at].desc.nulls_last,
        created_at: :desc,
      )

      vendors_condition(scope)
    end

    def filters
      [
        {
          type: :checkboxes,
          heading: 'Vendors',
          name: 'vendor_ids',
          options: Vendor.all.map do |vendor|
            {
              value: vendor.id,
              label: vendor.name,
              checked: applied_filters[:vendor_ids]&.include?(vendor.id.to_s),
            }
          end,
        },
      ]
    end

  private

    def vendors_condition(scope)
      return scope if applied_filters[:vendor_ids].blank?

      scope.left_joins(:provider)
        .where(providers: { vendor_id: applied_filters[:vendor_ids] })
    end
  end
end

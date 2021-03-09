module SupportInterface
  class SubReasonsForRejectionTableComponent < ViewComponent::Base
    include ViewHelper
    attr_accessor :reason, :sub_reasons, :total

    def initialize(reason:, sub_reasons:, total:)
      @reason = reason
      @sub_reasons = sub_reasons
      @total = total
    end

    def reason_label
      I18n.t("reasons_for_rejection.#{reason}.title")
    end

    def sub_reason_key
      ReasonsForRejectionCountQuery::TOP_LEVEL_REASONS_TO_SUB_REASONS[reason]
    end

    def sub_reason_label(sub_reason)
      I18n.t("reasons_for_rejection.#{ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[reason]}.#{sub_reason}")
    end

    def sub_reason_percentage(sub_reason_key)
      sub_reason_result = sub_reasons[sub_reason_key]
      formatted_percentage(sub_reason_result&.all_time || 0, total)
    end
  end
end

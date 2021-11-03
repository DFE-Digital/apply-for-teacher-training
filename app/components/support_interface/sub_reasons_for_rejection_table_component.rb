module SupportInterface
  class SubReasonsForRejectionTableComponent < ViewComponent::Base
    include ViewHelper
    attr_accessor :reason, :sub_reasons, :total_all_time, :total_this_month, :total_for_reason_all_time,
                  :total_for_reason_this_month, :recruitment_cycle_year

    def initialize(reason:, sub_reasons:, total_all_time:, total_this_month:, total_for_reason_all_time:,
                   total_for_reason_this_month:, recruitment_cycle_year: RecruitmentCycle.current_year)
      @reason = reason
      @sub_reasons = sub_reasons
      @total_all_time = total_all_time
      @total_this_month = total_this_month
      @total_for_reason_all_time = total_for_reason_all_time
      @total_for_reason_this_month = total_for_reason_this_month
      @recruitment_cycle_year = recruitment_cycle_year
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

    def sub_reason_percentage_of_reason(sub_reason_key, time_period = :all_time)
      formatted_percentage(sub_reason_count(sub_reason_key, time_period) || 0, total_for_reason(time_period))
    end

    def sub_reason_percentage(sub_reason_key, time_period = :all_time)
      formatted_percentage(sub_reason_count(sub_reason_key, time_period) || 0, total(time_period))
    end

    def sub_reason_count(sub_reason_key, time_period = :all_time)
      sub_reason_result = sub_reasons[sub_reason_key]
      sub_reason_result&.send(time_period)
    end

    def total_for_reason(time_period = :all_time)
      send(:"total_for_reason_#{time_period}")
    end

    def total(time_period)
      send(:"total_#{time_period}")
    end

    def month_name
      Time.zone.today.strftime('%B')
    end
  end
end

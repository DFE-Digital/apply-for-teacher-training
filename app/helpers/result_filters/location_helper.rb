module ResultFilters
  module LocationHelper
    def provider_error?
      return false if flash[:error].nil?

      flash[:error].include?(t("location_filter.fields.provider")) ||
        flash[:error].include?(t("location_filter.errors.blank_provider")) ||
        flash[:error].include?(t("location_filter.errors.missing_provider")) ||
        flash[:error].include?(t("location_filter.errors.invalid_provider"))
    end

    def location_error?
      return false if flash[:error].nil?

      flash[:error].include?(I18n.t("location_filter.fields.location"))
    end

    def no_option_selected?
      return false if flash[:error].nil?

      flash[:error].include?(I18n.t("location_filter.errors.no_option"))
    end
  end
end

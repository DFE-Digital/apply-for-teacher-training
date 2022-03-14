class FormatResidencyDetailsService
  def initialize(application_form:)
    @application_form = application_form
  end

  def residency_details_value
    if @application_form.eu_settled? || @application_form.eu_pre_settled?
      I18n.t("application_form.personal_details.immigration_status.values.#{@application_form.immigration_status}")
    else
      @application_form.right_to_work_or_study_details
    end
  end
end

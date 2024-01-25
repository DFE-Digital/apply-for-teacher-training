class FormatResidencyDetailsService
  def initialize(application_form:)
    @application_form = application_form
  end

  def residency_details_value
    if @application_form.defined_immigration_status?
      I18n.t("application_form.personal_details.immigration_status.values.#{@application_form.immigration_status}")
    else
      @application_form.right_to_work_or_study_details
    end
  end

private

  def ineligible_for_immigration_status?
    @application_form.other? || @application_form.immigration_status.blank?
  end

  def immigration_status_translation
    I18n.t("application_form.personal_details.immigration_status.values.#{@application_form.immigration_status}")
  end
end

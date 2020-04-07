class SafeguardingStatus
  attr_reader :application_form, :i18n_key

  def initialize(application_form:, i18n_key:)
    @application_form = application_form
    @i18n_key = i18n_key
  end

  def message
    if has_no_answer?
      I18n.t("#{i18n_key}.no_answer_message")
    elsif has_disclosed_safeguarding_issues?
      I18n.t("#{i18n_key}.has_disclosed_message")
    else
      I18n.t("#{i18n_key}.no_info_message")
    end
  end

private

  def has_disclosed_safeguarding_issues?
    @application_form.safeguarding_issues != 'No'
  end

  def has_no_answer?
    @application_form.safeguarding_issues.blank?
  end
end

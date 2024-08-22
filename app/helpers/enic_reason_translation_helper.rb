module EnicReasonTranslationHelper
  def translate_enic_reason(enic_reason)
    return t('gcse_edit_enic.not_entered') if enic_reason.nil?

    t("gcse_edit_enic.#{enic_reason}")
  end
end

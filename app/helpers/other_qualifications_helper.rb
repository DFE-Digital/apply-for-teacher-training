module OtherQualificationsHelper
  def other_qualifications_title(application_form)
    if application_form.international?
      I18n.t('page_titles.other_qualifications_international')
    else
      I18n.t('page_titles.other_qualifications')
    end
  end
end

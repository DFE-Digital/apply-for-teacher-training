module OtherQualificationsHelper
  def other_qualifications_title(application_form)
    if params[:controller] == 'candidate_interface/other_qualifications/review'
      I18n.t('page_titles.other_qualifications_review')
    elsif application_form.international_applicant?
      I18n.t('page_titles.other_qualifications_international')
    else
      I18n.t('page_titles.other_qualifications')
    end
  end
end

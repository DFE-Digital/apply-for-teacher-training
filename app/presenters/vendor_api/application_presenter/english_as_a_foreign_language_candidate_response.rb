module VendorAPI::ApplicationPresenter::EnglishAsAForeignLanguageCandidateResponse
  def schema
    super.deep_merge!({
      attributes: {
        candidate: {
          obtaining_english_language_qualification_details:,
        },
      },
    })
  end

  def english_proficiency
    @english_proficiency ||= application_form&.english_proficiency
  end

  def obtaining_english_language_qualification_details
    return nil unless english_proficiency.present?

    english_proficiency.no_qualification_details.presence || english_proficiency.no_assessment_plan_details
  end
end

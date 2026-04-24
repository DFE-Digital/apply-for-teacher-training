module VendorAPI::ApplicationPresenter::EnglishAsAForeignLanguageCandidateResponse
  def schema
    super.deep_merge!({
      attributes: {
        candidate: {
          will_obtain_english_language_qualifications:,
          obtaining_english_language_qualification_details:,
        },
      },
    })
  end

  def english_proficiency
    @english_proficiency ||= application_form&.english_proficiency
  end

  def will_obtain_english_language_qualifications
    english_proficiency&.no_qualification_details.present?
  end

  def obtaining_english_language_qualification_details
    english_proficiency&.no_qualification_details
  end
end

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

  def published_english_proficiency
    @published_english_proficiency ||= application_form&.published_english_proficiency
  end

  def will_obtain_english_language_qualifications
    published_english_proficiency&.no_qualification_details.present?
  end

  def obtaining_english_language_qualification_details
    published_english_proficiency&.no_qualification_details
  end
end

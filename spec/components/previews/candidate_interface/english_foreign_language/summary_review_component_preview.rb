class CandidateInterface::EnglishForeignLanguage::SummaryReviewComponentPreview < ViewComponent::Preview
  def with_ielts_qualification
    application_form = FactoryBot.create(:application_form, first_nationality: 'Iranian')
    FactoryBot.create(
      :english_proficiency,
      :with_ielts_qualification,
      application_form:,
    )

    render(CandidateInterface::EnglishForeignLanguage::SummaryReviewComponent.new(application_form:))
  end

  def with_toefl_qualification
    application_form = FactoryBot.create(:application_form, first_nationality: 'South African')
    FactoryBot.create(
      :english_proficiency,
      :with_toefl_qualification,
      application_form:,
    )

    render(CandidateInterface::EnglishForeignLanguage::SummaryReviewComponent.new(application_form:))
  end

  def with_other_qualification
    application_form = FactoryBot.create(:application_form, first_nationality: 'Argentinian')
    FactoryBot.create(
      :english_proficiency,
      :with_other_efl_qualification,
      application_form:,
    )

    render(CandidateInterface::EnglishForeignLanguage::SummaryReviewComponent.new(application_form:))
  end

  def no_qualification
    application_form = FactoryBot.create(:application_form, first_nationality: 'French')
    FactoryBot.create(
      :english_proficiency,
      :no_qualification,
      application_form:,
      no_qualification_details: 'I’m working on it.',
    )

    render(CandidateInterface::EnglishForeignLanguage::SummaryReviewComponent.new(application_form:))
  end

  def qualification_not_needed
    application_form = FactoryBot.create(:application_form, first_nationality: 'Polish')
    FactoryBot.create(
      :english_proficiency,
      :qualification_not_needed,
      application_form:,
    )

    render(CandidateInterface::EnglishForeignLanguage::SummaryReviewComponent.new(application_form:))
  end
end

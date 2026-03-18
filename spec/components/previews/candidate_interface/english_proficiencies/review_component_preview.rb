class CandidateInterface::EnglishProficiencies::ReviewComponentPreview < ViewComponent::Preview
  def qualification_not_needed
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      :qualification_not_needed,
      qualification_not_needed: true,
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def no_qualification
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      no_qualification: true,
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def no_qualification_with_details
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      no_qualification: true,
      no_qualification_details: 'Work in progress',
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def degree_taught_in_english
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      degree_taught_in_english: true,
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def degree_taught_in_english_with_details
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      degree_taught_in_english: true,
      no_qualification_details: 'Work in progress',
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def degree_taught_in_english_and_qualification_not_needed
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      qualification_not_needed: true,
      degree_taught_in_english: true,
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def with_ielts_qualification
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      :with_ielts_qualification,
      has_qualification: true,
      efl_qualification: FactoryBot.build_stubbed(:ielts_qualification),
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def with_ielts_qualification_and_qualification_not_needed
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      :with_ielts_qualification,
      has_qualification: true,
      qualification_not_needed: true,
      efl_qualification: FactoryBot.build_stubbed(:ielts_qualification),
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def with_ielts_qualification_and_qualification_not_needed_and_degree_taught_in_english
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      :with_ielts_qualification,
      has_qualification: true,
      qualification_not_needed: true,
      degree_taught_in_english: true,
      efl_qualification: FactoryBot.build_stubbed(:ielts_qualification),
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def with_toefl_qualification
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      :with_toefl_qualification,
      has_qualification: true,
      efl_qualification: FactoryBot.build_stubbed(:toefl_qualification),
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end

  def with_other_qualification
    english_proficiency = FactoryBot.build_stubbed(
      :english_proficiency,
      :with_other_efl_qualification,
      has_qualification: true,
      efl_qualification: FactoryBot.build_stubbed(:other_efl_qualification),
    )

    render(CandidateInterface::EnglishProficiencies::ReviewComponent.new(english_proficiency))
  end
end

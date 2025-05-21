class ProviderInterface::FindCandidates::OtherQualificationsComponentPreview < ViewComponent::Preview
  def double_science_gcse
    qualification = FactoryBot.create(
      :other_qualification,
      level: 'other',
      qualification_type: 'GCSE',
      subject: 'Double award Science (Double award)',
      grade: 'CC',
      award_year: 2007,
      other_uk_qualification_type: nil,
      non_uk_qualification_type: nil,
    )

    render ProviderInterface::FindCandidates::OtherQualificationsComponent.new(qualification.application_form)
  end
end

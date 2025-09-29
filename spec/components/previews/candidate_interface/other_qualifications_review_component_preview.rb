class CandidateInterface::OtherQualificationsReviewComponentPreview < ViewComponent::Preview
  def no_a_levels
    render(
      CandidateInterface::OtherQualificationsReviewComponent.new(
        application_form: FactoryBot.build(:application_form),
      ),
    )
  end
end

class ProviderInterface::FindCandidates::DegreesTableComponentPreview < ViewComponent::Preview
  def degrees_table_for_find_candidate_view
    application_form = FactoryBot.create(:application_form)
    # UK degree
    FactoryBot.create(:degree_qualification, predicted_grade: false, application_form:)
    # International with ENIC
    FactoryBot.create(:non_uk_degree_qualification, application_form:)
    # International without ENIC
    FactoryBot.create(:non_uk_degree_qualification, enic_reason: 'waiting', enic_reference: nil, application_form:)

    render ProviderInterface::FindCandidates::DegreesTableComponent.new(application_form)
  end
end

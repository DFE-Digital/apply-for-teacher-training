class ProviderInterface::FindCandidates::GcseQualificationsTableComponentPreview < ViewComponent::Preview
  def non_standard_gcse_table_for_find_candidates
    application_form = FactoryBot.build(:application_form)

    # International with ENIC, science
    FactoryBot.create(:gcse_qualification, :non_uk, subject: 'science', application_form:)

    # Retaking GCSE
    FactoryBot.create(:gcse_qualification, :missing_and_currently_completing, subject: 'maths', application_form:)

    # Missing and not retaking, English, lots of text
    FactoryBot.create(
      :gcse_qualification,
      :missing_and_not_currently_completing,
      subject: 'english',
      missing_explanation: Faker::Lorem.sentence(word_count: 200),
      application_form:,
    )

    render ProviderInterface::FindCandidates::GcseQualificationsTableComponent.new(application_form)
  end

  def gcse_table_for_uk_find_candidates
    application_form = FactoryBot.build(:application_form)
    %w[maths english science].each do |gcse_subject|
      FactoryBot.create(:gcse_qualification, subject: gcse_subject, application_form:)
    end
    render ProviderInterface::FindCandidates::GcseQualificationsTableComponent.new(application_form)
  end
end

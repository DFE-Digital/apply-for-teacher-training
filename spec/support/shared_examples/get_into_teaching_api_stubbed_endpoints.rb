RSpec.shared_context 'get into teaching api stubbed endpoints' do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::LookupItemsApi)
      .to receive(:get_teaching_subjects) { [preferred_teaching_subject].compact }

    allow_any_instance_of(GetIntoTeachingApiClient::LookupItemsApi)
      .to receive(:get_countries) { [country].compact }

    allow_any_instance_of(GetIntoTeachingApiClient::PickListItemsApi)
      .to receive(:get_candidate_initial_teacher_training_years) { [this_year, next_year].compact }

    allow_any_instance_of(GetIntoTeachingApiClient::PrivacyPoliciesApi)
      .to receive(:get_latest_privacy_policy) { privacy_policy }
  end

  let(:this_year) { GetIntoTeachingApiClient::PickListItem.new(id: 1, value: Time.zone.today.year.to_s) }
  let(:next_year) { GetIntoTeachingApiClient::PickListItem.new(id: 2, value: 1.year.from_now.year.to_s) }
  let(:privacy_policy) { GetIntoTeachingApiClient::PrivacyPolicy.new(id: SecureRandom.uuid, text: 'Privacy policy') }
  let(:country) { GetIntoTeachingApiClient::Country.new(id: SecureRandom.uuid, iso_code: 'GB') }
  let(:preferred_teaching_subject) { GetIntoTeachingApiClient::TeachingSubject.new(id: SecureRandom.uuid, value: 'Maths') }
end

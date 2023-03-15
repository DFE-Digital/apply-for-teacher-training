RSpec.shared_context 'get into teaching api stubbed endpoints' do
  before do
    allow(GetIntoTeachingApiClient::LookupItemsApi).to receive(:new).and_return(lookup_items_api_double)
    allow(lookup_items_api_double).to receive(:get_teaching_subjects) { [preferred_teaching_subject, primary_teaching_subject, excluded_teaching_subject].compact }
    allow(lookup_items_api_double).to receive(:get_countries) { [country].compact }

    pick_list_items_api_double = instance_double(GetIntoTeachingApiClient::PickListItemsApi)
    allow(GetIntoTeachingApiClient::PickListItemsApi).to receive(:new).and_return(pick_list_items_api_double)
    allow(pick_list_items_api_double).to receive(:get_candidate_initial_teacher_training_years) { [this_year, next_year].compact }

    privacy_policies_api_double = instance_double(GetIntoTeachingApiClient::PrivacyPoliciesApi)
    allow(GetIntoTeachingApiClient::PrivacyPoliciesApi).to receive(:new).and_return(privacy_policies_api_double)
    allow(privacy_policies_api_double).to receive(:get_latest_privacy_policy) { privacy_policy }
  end

  let(:lookup_items_api_double) { instance_double(GetIntoTeachingApiClient::LookupItemsApi) }
  let(:this_year) { GetIntoTeachingApiClient::PickListItem.new(id: 1, value: Time.zone.today.year.to_s) }
  let(:next_year) { GetIntoTeachingApiClient::PickListItem.new(id: 2, value: 1.year.from_now.year.to_s) }
  let(:privacy_policy) { GetIntoTeachingApiClient::PrivacyPolicy.new(id: SecureRandom.uuid, text: 'Privacy policy') }
  let(:country) { GetIntoTeachingApiClient::Country.new(id: SecureRandom.uuid, iso_code: 'GB') }
  let(:preferred_teaching_subject) { GetIntoTeachingApiClient::TeachingSubject.new(id: SecureRandom.uuid, value: 'Maths') }
  let(:primary_teaching_subject) { GetIntoTeachingApiClient::TeachingSubject.new(id: Adviser::Constants.fetch(:teaching_subjects, :primary), value: 'Primary') }
  let(:excluded_teaching_subject) { GetIntoTeachingApiClient::TeachingSubject.new(id: Adviser::Constants.fetch(:teaching_subjects, :excluded).values.sample, value: 'Excluded') }
end

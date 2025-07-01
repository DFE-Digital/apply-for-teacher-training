require 'rails_helper'

RSpec.describe ProviderInterface::CandidateInvitesFilter do
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
  let(:provider) { application_choice.provider }

  let(:invite_with_application) do
    create(
      :pool_invite,
      :sent_to_candidate,
      course: application_choice.course,
      application_form: application_choice.application_form,
    )
  end

  let(:opted_out_preference) { create(:candidate_preference, pool_status: 'opt_out') }
  let(:opt_out_form) { create(:application_form, candidate: opted_out_preference.candidate) }
  let(:invite_with_opted_out_candidate) { create(:pool_invite, :sent_to_candidate, course: build(:course, provider:), application_form: opt_out_form) }

  let(:opted_in_preference) { create(:candidate_preference, :anywhere_in_england, pool_status: 'opt_in') }
  let(:opt_in_form) { create(:application_form, candidate: opted_in_preference.candidate) }
  let(:invite_with_candidate_in_pool) { create(:pool_invite, :sent_to_candidate, application_form: opt_in_form, course: build(:course, provider:)) }
  let(:second_invite_with_candidate_in_pool) { create(:pool_invite, :sent_to_candidate, application_form: opt_in_form, course: build(:course, provider:)) }

  let(:provider_user) { create(:provider_user, provider_ids: [provider.id]) }

  before do
    invite_with_application
    invite_with_opted_out_candidate
    invite_with_candidate_in_pool
    second_invite_with_candidate_in_pool

    FindACandidate::PopulatePoolWorker.new.perform
  end

  context 'user does not have saved filters and no filter_params provided' do
    it 'returns all invites for provider' do
      filter = described_class.new(filter_params: {}, provider_user:)
      expect(filter.applied_filters)
        .to contain_exactly(
          invite_with_application,
          invite_with_opted_out_candidate,
          invite_with_candidate_in_pool,
          second_invite_with_candidate_in_pool,
        )
      expect(filter.candidate_count).to eq 3
    end
  end

  context 'user does have saved filters and new filter_params are provided' do
    it 'updates the filter_params and returns filtered courses' do
      user_filter = create(:provider_user_filter, :find_candidates_invited, provider_user:, filters: { status: ['invited'] })
      filter_params = ActionController::Parameters.new({ 'status' => [], 'courses' => [invite_with_application.course.id] })

      filter = described_class.new(filter_params:, provider_user:)
      expect(filter.applied_filters).to contain_exactly(invite_with_application)
      expect(filter.candidate_count).to eq 1
      expect(user_filter.reload.filters).to match({ 'courses' => [invite_with_application.course.id] })
    end
  end

  context 'user has saved filters and no filter params are provided' do
    it 'returns filtered list based on saved filters, filters are not updated' do
      user_filter = create(:provider_user_filter, :find_candidates_invited, provider_user:, filters: { status: ['invited'] })
      filter = described_class.new(filter_params: {}, provider_user:)

      expect(filter.applied_filters)
        .to contain_exactly(
          invite_with_opted_out_candidate,
          invite_with_candidate_in_pool,
          second_invite_with_candidate_in_pool,
        )

      expect(filter.candidate_count).to eq 2
      expect(user_filter.reload.filters).to match({ 'status' => ['invited'] })
    end
  end
end

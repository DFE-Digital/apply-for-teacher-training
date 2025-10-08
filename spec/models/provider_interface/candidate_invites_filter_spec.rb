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
      candidate_decision: 'accepted',
    )
  end

  let(:opted_out_preference) { create(:candidate_preference, pool_status: 'opt_out') }
  let(:invite_with_opted_out_candidate) do
    create(
      :pool_invite,
      :sent_to_candidate,
      course: build(:course, provider:),
      application_form: opted_out_preference.application_form,
    )
  end

  let(:opted_in_preference) { create(:candidate_preference, :anywhere_in_england, pool_status: 'opt_in') }
  let(:invite_with_candidate_in_pool) do
    create(
      :pool_invite,
      :sent_to_candidate,
      application_form: opted_out_preference.application_form,
      course: build(:course, provider:),
    )
  end
  let(:second_invite_with_candidate_in_pool) do
    create(
      :pool_invite,
      :sent_to_candidate,
      application_form: opted_in_preference.application_form,
      course: build(:course, provider:),
    )
  end

  let(:declined_invite) do
    create(
      :pool_invite,
      :sent_to_candidate,
      application_form: opted_in_preference.application_form,
      course: build(:course, provider:),
      candidate_decision: 'declined',
    )
  end

  let(:provider_user) { create(:provider_user, provider_ids: [provider.id]) }

  before do
    invite_with_application
    invite_with_opted_out_candidate
    invite_with_candidate_in_pool
    second_invite_with_candidate_in_pool
    declined_invite

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
          declined_invite,
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

  context 'user applies the "Invited" filter' do
    it 'returns candidates with invites with a status of "Invited"' do
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

  context 'user applies the "Invite declined" filter' do
    it 'returns candidates with invites with a status of "Application declined"' do
      user_filter = create(:provider_user_filter, :find_candidates_invited, provider_user:, filters: { status: ['declined'] })
      filter = described_class.new(filter_params: {}, provider_user:)

      expect(filter.applied_filters)
        .to contain_exactly(
          declined_invite,
        )

      expect(filter.candidate_count).to eq 1
      expect(user_filter.reload.filters).to match({ 'status' => ['declined'] })
    end
  end

  context 'user applies the "Application received" filter' do
    it 'returns candidates with invites with a status of "Application received"' do
      user_filter = create(:provider_user_filter, :find_candidates_invited, provider_user:, filters: { status: ['application_received'] })
      filter = described_class.new(filter_params: {}, provider_user:)

      expect(filter.applied_filters)
        .to contain_exactly(
          invite_with_application,
        )

      expect(filter.candidate_count).to eq 1
      expect(user_filter.reload.filters).to match({ 'status' => ['application_received'] })
    end
  end

  context 'user applies the "Invited" and "Application received" filters' do
    it 'returns candidates with invites with a status of "Application received" and "Invited"' do
      user_filter = create(:provider_user_filter, :find_candidates_invited, provider_user:, filters: { status: %w[application_received invited] })
      filter = described_class.new(filter_params: {}, provider_user:)

      expect(filter.applied_filters)
        .to contain_exactly(
          invite_with_application,
          invite_with_opted_out_candidate,
          invite_with_candidate_in_pool,
          second_invite_with_candidate_in_pool,
        )

      expect(filter.candidate_count).to eq 3
      expect(user_filter.reload.filters).to match({ 'status' => %w[application_received invited] })
    end
  end
end

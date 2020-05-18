require 'rails_helper'

RSpec.describe ProviderInterface::ProviderApplicationsPageState do
  let(:provider_user) { create(:provider_user, :with_two_providers) }

  describe '#filters' do
    it 'calculates a correct list of possible filters' do
      page_state = described_class.new(params: ActionController::Parameters.new,
                                       provider_user: provider_user)

      expect(page_state.filters).to be_a(Array)
      expect(page_state.filters.size).to be(4)
    end
  end

  describe '#applied_filters' do
    let(:params) do
      ActionController::Parameters.new({ 'status' => %w[
        awaiting_provider_decision
        pending_conditions
        recruited
        declined
      ],
                                         'weekdays' => %w[
                                           wed
                                           thurs
                                           mon
                                         ] })
    end

    it 'returns a has of permitted parameters' do
      page_state = described_class.new(params: params, provider_user: provider_user)

      expect(page_state.applied_filters).to be_a(Hash)
      expect(page_state.applied_filters.keys).to include('status')
      expect(page_state.applied_filters.keys).not_to include('weekdays')
    end
  end

  describe '#filtered?' do
    let(:params) do
      ActionController::Parameters.new({ 'status' => %w[
        awaiting_provider_decision
        pending_conditions
        recruited
        declined
      ] })
    end

    let(:empty_params) { ActionController::Parameters.new }

    it 'returns true if filers have been applied' do
      page_state = described_class.new(params: params, provider_user: provider_user)
      expect(page_state.filtered?).to be(true)
    end

    it 'returns false if filters have not been applied' do
      page_state = described_class.new(params: empty_params, provider_user: provider_user)
      expect(page_state.filtered?).to be(false)
    end
  end
end

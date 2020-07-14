require 'rails_helper'

RSpec.describe ProviderInterface::SortOrderComponent do
  describe 'rendering' do
    let(:provider_user) { build_stubbed(:provider_user) }
    let(:params) do
      ActionController::Parameters.new({
        'status' => %w[awaiting_provider_decision pending_conditions],
        'candidate_name' => 'Susan',
      })
    end
    let(:page_state) do
      ProviderInterface::ProviderApplicationsPageState.new(params: params, provider_user: provider_user, state_store: {})
    end

    subject(:rendered_result) { render_inline(described_class.new(page_state: page_state)) }

    it 'renders sorting ordering options' do
      expect(rendered_result.css('select').text).to include('Last changed')
      expect(rendered_result.css('select').text).to include('Days left to respond')
    end

    it 'renders a sort button' do
      expect(rendered_result.css('input[type=submit]').attr('value').value).to include('Sort')
    end

    it 'renders applied filters as hidden fields' do
      expect(rendered_result.css('input[type=hidden][name="status[]"]').first.attr('value')).to eq('awaiting_provider_decision')
      expect(rendered_result.css('input[type=hidden][name="status[]"]').last.attr('value')).to eq('pending_conditions')
      expect(rendered_result.css('input[type=hidden][name=candidate_name]').attr('value').value).to eq('Susan')
    end
  end
end

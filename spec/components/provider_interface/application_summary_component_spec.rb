require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationSummaryComponent do
  describe '#rows' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form) }

    subject { described_class.new(application_choice: application_choice).rows }

    context 'application_number_replacement feature activated' do
      before { FeatureFlag.activate(:application_number_replacement) }

      let(:expected) { { key: 'Application number', value: application_choice.id } }

      it { is_expected.to include(expected) }
    end

    context 'application_number_replacement feature deactivated' do
      before { FeatureFlag.deactivate(:application_number_replacement) }

      let(:expected) { { key: 'Reference', value: application_choice.application_form.support_reference } }

      it { is_expected.to include(expected) }
    end
  end
end

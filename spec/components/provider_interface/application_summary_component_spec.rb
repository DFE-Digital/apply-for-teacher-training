require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationSummaryComponent do
  describe '#rows' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form) }
    let(:expected) { { key: 'Application number', value: application_choice.id } }

    subject { described_class.new(application_choice:).rows }

    it { is_expected.to include(expected) }
  end
end

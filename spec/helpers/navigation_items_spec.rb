require 'rails_helper'

RSpec.describe NavigationItems do
  describe '.for_candidate_primary_nav' do
    context 'when no candidate is provided' do
      it 'renders the correct items' do
        expect(described_class.for_candidate_primary_nav(nil, nil).map(&:text)).to eq([])
      end
    end

    context 'when application choice is in unsubmitted state' do
      let(:candidate) { create(:candidate, application_forms: [create(:application_form, application_choices: [build(:application_choice, :unsubmitted)])]) }

      it 'renders the correct items' do
        expect(described_class.for_candidate_primary_nav(candidate, nil).map(&:text)).to eq(['Your application'])
      end
    end

    context 'when application choice is in accepted state' do
      let(:candidate) do
        create(:candidate, application_forms: [create(:application_form, application_choices: [build(:application_choice, :pending_conditions)])])
      end

      it 'renders the correct items' do
        expect(described_class.for_candidate_primary_nav(candidate, nil).map(&:text)).to eq(['Your offer'])
      end
    end
  end
end

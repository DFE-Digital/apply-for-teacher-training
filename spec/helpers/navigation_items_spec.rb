require 'rails_helper'

RSpec.describe NavigationItems do
  let(:current_application) { current_candidate.current_application }

  describe '.candidate_primary_navigation' do
    let(:current_candidate) { nil }
    let(:current_controller) { nil }

    subject(:navigation_items) { described_class.candidate_primary_navigation(current_candidate:, current_controller:) }

    context 'when no candidate is provided' do
      it 'contains no navigation items' do
        expect(navigation_items).to eq([])
      end
    end

    context 'when candidate is provided' do
      let(:current_candidate) { create(:candidate, application_forms: [create(:application_form, application_choices:)]) }

      context 'when application choice is in unsubmitted state' do
        let(:application_choices) { [build(:application_choice, :unsubmitted)] }

        it 'contains the "Your details" and "Your applications" navigation items, neither are in the active state' do
          expect(navigation_items).to contain_exactly(
            have_attributes(text: 'Your details', active: false), # both false as the controller does not implement #choices_controller?
            have_attributes(text: 'Your applications', active: false), # both false as the controller does not implement #choices_controller?
          )
        end
      end

      context 'when application choice is in accepted state' do
        let(:application_choices) { [build(:application_choice, :pending_conditions)] }

        it 'contains only the "Your offer" navigation item in the active state' do
          expect(navigation_items).to contain_exactly(
            have_attributes(text: 'Your offer', active: true),
          )
        end
      end
    end

    context 'when application_choice is unsubmitted and the controller is not a choices controller' do
      let(:current_candidate) { create(:candidate, application_forms: [create(:application_form, application_choices: build_list(:application_choice, 1, :unsubmitted))]) }
      let(:current_controller) { instance_double(CandidateInterface::CandidateInterfaceController, choices_controller?: false) }

      it 'contains the "Your details" and "Your applications" navigation items, with "Your details" in the active state' do
        expect(navigation_items).to contain_exactly(
          have_attributes(text: 'Your details', active: true),
          have_attributes(text: 'Your applications', active: false),
        )
      end
    end

    context 'when application_choice is unsubmitted and the controller is a choices controller' do
      let(:current_candidate) { create(:candidate, application_forms: [create(:application_form, application_choices: build_list(:application_choice, 1, :unsubmitted))]) }
      let(:current_controller) { instance_double(CandidateInterface::CandidateInterfaceController, choices_controller?: true) }

      it 'contains the "Your details" and "Your applications" navigation items, with "Your applications" in the active state' do
        expect(navigation_items).to contain_exactly(
          have_attributes(text: 'Your details', active: false),
          have_attributes(text: 'Your applications', active: true),
        )
      end
    end
  end

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

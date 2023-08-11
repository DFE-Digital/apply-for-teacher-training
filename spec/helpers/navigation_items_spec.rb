require 'rails_helper'

RSpec.describe NavigationItems do
  let(:current_application) { current_candidate.current_application }

  describe '.candidate_primary_navigation', continuous_applications: true do
    context 'when no candidate is provided' do
      it 'renders the correct items' do
        expect(described_class.candidate_primary_navigation(current_candidate: nil, current_controller: nil, current_application: nil).map(&:text)).to eq([])
      end
    end

    context 'when candidate is provided' do
      let(:current_controller) do
        instance_double(CandidateInterface::ContinuousApplicationsDetailsController, controller_name: 'continuous_applications_details')
      end
      let(:current_candidate) do
        create(:candidate, application_forms: [create(:application_form, application_choices: [build(:application_choice, :pending_conditions)])])
      end

      it 'renders the correct items' do
        expect(described_class.candidate_primary_navigation(current_candidate:, current_controller:, current_application:).map(&:text)).to eq(['Your details', 'Your application'])
      end
    end

    context 'when candidate has zero applications' do
      let(:current_controller) do
        instance_double(CandidateInterface::ContinuousApplicationsDetailsController, controller_name: 'continuous_applications_details')
      end
      let(:current_candidate) do
        create(:candidate, application_forms: [create(:application_form, application_choices: [])])
      end

      it 'renders the correct items' do
        expect(described_class.candidate_primary_navigation(current_candidate:, current_controller:, current_application:).map(&:text)).to eq(['Your details', 'Your application'])
      end
    end

    context 'when candidate has many applications' do
      let(:current_controller) do
        instance_double(CandidateInterface::ContinuousApplicationsDetailsController, controller_name: 'continuous_applications_details')
      end
      let(:current_candidate) do
        create(:candidate, application_forms: [create(:application_form, application_choices: [build(:application_choice, :pending_conditions), build(:application_choice, :unsubmitted)])])
      end
      let(:current_application) { current_candidate.current_application }

      it 'pluralizes the applications title' do
        expect(described_class.candidate_primary_navigation(current_candidate:, current_controller:, current_application:).map(&:text)).to eq(['Your details', 'Your applications'])
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

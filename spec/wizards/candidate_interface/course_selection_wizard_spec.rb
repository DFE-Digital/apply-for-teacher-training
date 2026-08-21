require 'rails_helper'

RSpec.describe CandidateInterface::CourseSelectionWizard, type: :model do
  describe 'steps' do
    subject(:wizard) { described_class.new(state_store:) }

    let(:state_store) do
      CandidateInterface::StateStores::CourseSelectionWizardStore.new(
        repository: DfE::Wizard::Repository::Session.new(
          session: {},
          key: :test_candidate_interface_course_selection_wizard,
        ),
      )
    end
    let(:session) { {} }

    describe 'root_step' do
      it 'returns the :do_you_know_the_course as the root step' do
        expect(wizard.root_step).to eq(:do_you_know_the_course)
      end
    end

    describe 'next_step/branching' do
      it { is_expected.to have_next_step(:go_to_find_explanation) }
      it { is_expected.to have_next_step(:provider_selection).when(answer: 'yes') }

      it { is_expected.to branch_from(:provider_selection).to(:which_course_are_you_applying_to) }
    end
  end
end

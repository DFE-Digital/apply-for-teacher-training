require 'rails_helper'

RSpec.describe CandidateInterface::CourseSelectionWizard, type: :model do
  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:state_store) { CandidateInterface::StateStores::CourseSelectionWizardStore.new(repository:) }

  describe 'delegations' do
    subject(:wizard) { described_class.new(state_store:) }

    it { is_expected.to delegate_method(:know_the_course_to_apply?).to(:state_store) }
    it { is_expected.to delegate_method(:reapplication_limit_reached?).to(:state_store) }
    it { is_expected.to delegate_method(:duplicate_course?).to(:state_store) }
    it { is_expected.to delegate_method(:course_closed?).to(:state_store) }
    it { is_expected.to delegate_method(:course_unavailable?).to(:state_store) }
    it { is_expected.to delegate_method(:multiple_study_modes?).to(:state_store) }
    it { is_expected.to delegate_method(:multiple_sites?).to(:state_store) }
    it { is_expected.to delegate_method(:not_multiple_sites?).to(:state_store) }
    it { is_expected.to delegate_method(:provider).to(:state_store) }
    it { is_expected.to delegate_method(:provider_exists?).to(:state_store) }
    it { is_expected.to delegate_method(:course).to(:state_store) }
    it { is_expected.to delegate_method(:course_id).to(:state_store) }
    it { is_expected.to delegate_method(:find_course_selected?).to(:state_store) }
    it { is_expected.to delegate_method(:find_course_not_selected?).to(:state_store) }
    it { is_expected.to delegate_method(:not_multiple_sites_or_study_modes?).to(:state_store) }
    it { is_expected.to delegate_method(:visa_expires_soon?).to(:state_store) }
    it { is_expected.to delegate_method(:not_confirmed?).to(:state_store) }
  end

  describe 'steps' do
    subject(:wizard) do
      described_class.new(
        state_store:,
        current_step_params:,
      ).tap do |wizard|
        wizard.current_application = application_form
      end
    end

    let(:current_step_params) { { current_application_id: application_form.id } }
    let(:application_form) { create(:completed_application_form) }

    describe 'root_step' do
      it 'returns the :do_you_know_the_course as the root step' do
        expect(wizard.root_step).to eq(:do_you_know_the_course)
      end
    end

    describe 'next_steps' do
      it { is_expected.to have_next_step(:go_to_find_explanation) }
      it { is_expected.to have_next_step(:provider_selection).when(answer: 'yes') }
    end

    describe 'branching from provider_selection' do
      it { is_expected.to branch_from(:provider_selection).to(:which_course_are_you_applying_to) }
    end

    describe 'branching from which_course_are_you_applying_to' do
      context 'when the candidate has reached there application limit' do
        before { allow(state_store).to receive(:reapplication_limit_reached?).and_return(true) }

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:reached_reapplication_limit) }
      end

      context 'when the candidate has a duplicate course' do
        before do
          allow(state_store).to receive_messages(reapplication_limit_reached?: false, duplicate_course?: true)
        end

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:duplicate_course_selection) }
      end

      context 'when the candidate applies for a closed course' do
        before do
          allow(state_store).to receive_messages(reapplication_limit_reached?: false, duplicate_course?: false, course_closed?: true)
        end

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:closed_course_selection) }
      end

      context 'when the candidate applies for a course that is no longer available' do
        before do
          allow(state_store).to receive_messages(reapplication_limit_reached?: false, duplicate_course?: false, course_closed?: false, course_unavailable?: true)
        end

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:full_course_selection) }
      end

      context 'when the candidate applies for a course that has only one site and study mode' do
        before do
          allow(state_store).to receive_messages(reapplication_limit_reached?: false, duplicate_course?: false, course_closed?: false, course_unavailable?: false, not_multiple_sites_or_study_modes?: true)
        end

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:course_review) }
      end

      context 'when the candidate applies for a course that has multiple study modes' do
        before do
          allow(state_store).to receive_messages(reapplication_limit_reached?: false, duplicate_course?: false, course_closed?: false, course_unavailable?: false, not_multiple_sites_or_study_modes?: false, multiple_study_modes?: true)
        end

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:course_study_mode) }
      end

      context 'when the candidate applies for a course that has multiple course sites' do
        before do
          allow(state_store).to receive_messages(reapplication_limit_reached?: false, duplicate_course?: false, course_closed?: false, course_unavailable?: false, not_multiple_sites_or_study_modes?: false, multiple_study_modes?: false, multiple_sites?: true)
        end

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:course_site) }
      end

      context "when the candidate's visa expires soon" do
        before do
          allow(state_store).to receive_messages(reapplication_limit_reached?: false, duplicate_course?: false, course_closed?: false, course_unavailable?: false, not_multiple_sites_or_study_modes?: false, multiple_study_modes?: false, multiple_sites?: false, visa_expires_soon?: true)
        end

        it { is_expected.to branch_from(:which_course_are_you_applying_to).to(:visa_expiry_interruption) }
      end
    end

    describe 'branching from find_course_selection' do
      context 'when the candidate applies for a course that has multiple study modes' do
        before do
          allow(state_store).to receive(:multiple_study_modes?).and_return(true)
        end

        it { is_expected.to branch_from(:find_course_selection).to(:course_study_mode) }
      end

      context 'when the candidate applies for a course that has multiple sites' do
        before do
          allow(state_store).to receive_messages(multiple_study_modes?: false, multiple_sites?: true)
        end

        it { is_expected.to branch_from(:find_course_selection).to(:course_site) }
      end

      context "when the candidate's visa expires soon" do
        before do
          allow(state_store).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, visa_expires_soon?: true)
        end

        it { is_expected.to branch_from(:find_course_selection).to(:visa_expiry_interruption) }
      end

      context 'when the candidate applies for a course that has only one site and study mode' do
        before do
          allow(state_store).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, visa_expires_soon?: false, find_course_selected?: true)
        end

        it { is_expected.to branch_from(:find_course_selection).to(:course_review) }
      end

      context 'when the candidate does not confirm the course' do
        before do
          allow(state_store).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, visa_expires_soon?: false, find_course_selected?: false, not_confirmed?: true)
        end

        it { is_expected.to branch_from(:find_course_selection).to(:application_list) }
      end
    end

    describe 'branching from course_study_mode' do
      context 'when the candidate applies for a course that has multiple sites' do
        before do
          allow(state_store).to receive(:multiple_sites?).and_return(true)
        end

        it { is_expected.to branch_from(:course_study_mode).to(:course_site) }
      end

      context "when the candidate's visa expires soon" do
        before do
          allow(state_store).to receive_messages(multiple_sites?: false, visa_expires_soon?: true)
        end

        it { is_expected.to branch_from(:course_study_mode).to(:visa_expiry_interruption) }
      end

      context 'when the candidate applies for a course that has only one site' do
        before do
          allow(state_store).to receive_messages(multiple_sites?: false, visa_expires_soon?: false, not_multiple_sites?: true)
        end

        it { is_expected.to branch_from(:course_study_mode).to(:course_review) }
      end
    end

    describe 'branching from course_site' do
      context "when the candidate's visa expires soon" do
        before do
          allow(state_store).to receive(:visa_expires_soon?).and_return(true)
        end

        it { is_expected.to branch_from(:course_site).to(:visa_expiry_interruption) }
      end

      context "when the candidate's visa does not expire soon" do
        before do
          allow(state_store).to receive(:visa_expires_soon?).and_return(false)
        end

        it { is_expected.to branch_from(:course_site).to(:course_review) }
      end
    end

    describe 'branching from visa_expiry_interruption' do
      it { is_expected.to branch_from(:visa_expiry_interruption).to(:visa_explanation) }
    end

    describe 'branching from visa_explanation' do
      it { is_expected.to branch_from(:visa_explanation).to(:course_review) }
    end
  end
end

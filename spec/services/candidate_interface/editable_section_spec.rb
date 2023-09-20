require 'rails_helper'

RSpec.describe CandidateInterface::EditableSection do
  subject(:editable_section) do
    described_class.new(current_application:, controller_path:, action_name:, params:)
  end

  let(:current_application) { create(:application_form) }
  let(:controller_path) { '' }
  let(:action_name) { '' }
  let(:params) { {} }

  describe '#can_edit?' do
    context 'when candidate accepted an offer' do
      before do
        create(:application_choice, :accepted, application_form: current_application)
      end

      it 'returns true' do
        expect(editable_section.can_edit?).to be true
      end
    end

    context 'when candidate did not submitted yet' do
      it 'returns true' do
        expect(editable_section.can_edit?).to be true
      end
    end

    context 'when candidate already submitted at least once' do
      let(:application_form) { create(:application_form) }

      before do
        create(:application_choice, :awaiting_provider_decision, application_form: current_application)
      end

      context 'when accessing an editable section' do
        let(:controller_path) { 'candidate_interface/personal_details/review' }

        it 'returns true' do
          expect(editable_section.can_edit?).to be true
        end
      end

      context 'when accessing an non editable section' do
        let(:controller_path) { 'some-non-editable/controller' }

        it 'returns false' do
          expect(editable_section.can_edit?).to be false
        end
      end
    end
  end
end

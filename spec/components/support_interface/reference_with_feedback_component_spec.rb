require 'rails_helper'

RSpec.describe SupportInterface::ReferenceWithFeedbackComponent do
  include CandidateHelper

  let(:reference) { create(:reference) }
  let(:editable) { true }

  subject! { render_inline(described_class.new(reference: reference, reference_number: 1, editable: editable)) }

  context 'when editable' do
    it 'shows change links' do
      expect(page).to have_selector('a', text: 'Change')
    end
  end

  context 'when not editable' do
    let(:editable) { false }

    it 'shows change links' do
      expect(page).not_to have_selector('a', text: 'Change')
    end
  end

  describe 'Undo refusal link' do
    let(:reference) { create(:reference, feedback_status: 'feedback_refused') }

    it 'is present when the reference is refused' do
      expect(rendered_component).to include('Undo refusal')
    end

    context 'when not editable' do
      let(:editable) { false }

      it 'is not present' do
        expect(rendered_component).not_to include('Undo refusal')
      end
    end
  end

  describe 'title' do
    it 'includes the supplied reference number' do
      expect(rendered_component).to include('First referee')
    end

    it 'includes the id of the reference' do
      expect(rendered_component).to include("##{reference.id}")
    end

    context 'when a reference is a replacement' do
      let(:reference) { create(:reference, replacement: true) }

      it 'says that the reference is a replacement' do
        expect(rendered_component).to include('(replacement)')
      end
    end
  end

  describe 'selected row' do
    let(:reference) { create(:reference, selected: selected) }

    context 'when the reference is selected' do
      let(:selected) { true }

      it 'indicates selected' do
        within_summary_row('Selected?') do
          expect(page).to include 'Yes'
        end
      end
    end

    context 'when the reference is not selected' do
      let(:selected) { false }

      it 'indicates not selected' do
        within_summary_row('Selected?') do
          expect(page).to include 'No'
        end
      end
    end
  end
end

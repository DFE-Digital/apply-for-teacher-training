require 'rails_helper'

RSpec.describe SupportInterface::ReferenceWithFeedbackComponent, type: :component do
  include CandidateHelper

  let(:reference) {
    create(:reference,
           name: 'Jane Smith')
  }
  let(:editable) { true }

  before do
    render_inline(described_class.new(reference:, reference_number: 1, editable:))
  end

  context 'when editable' do
    it 'shows the name with a change link' do
      expect(rendered_content).to summarise(
        key: 'Name',
        value: 'Jane Smith',
        action: {
          text: 'Change',
          href: Rails.application.routes.url_helpers.support_interface_application_form_edit_reference_details_path(reference.application_form, reference),
        },
      )
    end
  end

  context 'when not editable' do
    let(:editable) { false }

    it 'does not include change links' do
      expect(rendered_content).not_to have_link('Change')
    end
  end

  describe 'Undo refusal link' do
    let(:reference) { create(:reference, feedback_status: 'feedback_refused') }

    it 'is present when the reference is refused' do
      expect(rendered_content).to include('Undo refusal')
    end

    context 'when not editable' do
      let(:editable) { false }

      it 'is not present' do
        expect(rendered_content).not_to include('Undo refusal')
      end
    end
  end

  describe 'title' do
    it 'contains the name of the person asked for a reference' do
      expect(rendered_content).to have_css('h3', text: 'Jane Smith')
    end
  end
end

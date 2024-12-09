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

  context 'when the reference has not been given yet' do
    let(:reference) {
      create(:reference, :not_requested_yet,
             name: 'Jane Smith',
             relationship: 'She was my tutor.')
    }

    it 'shows how the candidate said they knows them' do
      expect(rendered_content).to summarise(
        key: 'How the candidate knows them and how long for',
        value: 'She was my tutor.',
      )
    end
  end

  context 'when the relationship has been confirmed' do
    let(:reference) {
      create(:reference, :feedback_provided,
             name: 'Jane Smith',
             relationship: 'She was my tutor.',
             relationship_correction: nil)
    }

    it 'shows that the relationship was confirmed' do
      expect(rendered_content).to summarise(
        key: 'How the candidate knows them and how long for',
        value: 'She was my tutor.This was confirmed by Jane Smith',
      )
    end
  end

  context 'when the referee gave a different relationship answer' do
    let(:reference) {
      create(:reference,
             name: 'Jane Smith',
             relationship: 'She was my tutor for 2 years.',
             relationship_correction: 'She was a student for 1 year.',
             feedback_status: 'feedback_provided',
             feedback_provided_at: Time.zone.now)
    }

    it 'shows both the candidate and referee descriptions' do
      expect(rendered_content).to summarise(
        key: 'How the candidate knows them and how long for',
        value: 'She was my tutor for 2 years.Jane Smith said:She was a student for 1 year.',
      )
    end
  end

  context 'when not editable' do
    let(:editable) { false }

    it 'does not include change links' do
      expect(rendered_content).to have_no_link('Change')
    end
  end

  context 'when there is no referee_type saved (as it is an old reference)' do
    let(:reference) {
      create(:reference, :not_requested_yet,
             referee_type: nil)
    }

    it 'does not include the Type row' do
      expect(rendered_content).to have_no_content('Type')
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

  describe 'Confidentiality row' do
    context 'when the reference is confidential' do
      before do
        reference.update(confidential: true, feedback_status: 'feedback_provided')
        render_inline(described_class.new(reference:, reference_number: 1, editable:))
      end

      it 'shows that the reference is confidential' do
        expect(rendered_content).to summarise(
          key: 'Can this reference be shared with the candidate?',
          value: 'No, this reference is confidential. Do not share it.',
        )
      end
    end

    context 'when the reference is not confidential' do
      before do
        reference.update(confidential: false, feedback_status: 'feedback_provided')
        render_inline(described_class.new(reference:, reference_number: 1, editable:))
      end

      it 'shows that the reference is not confidential' do
        expect(rendered_content).to summarise(
          key: 'Can this reference be shared with the candidate?',
          value: 'Yes, if they request it.',
        )
      end
    end

    context 'when feedback has not been provided' do
      before do
        reference.update(confidential: true, feedback_status: 'feedback_requested')
        render_inline(described_class.new(reference:, reference_number: 1, editable:))
      end

      it 'does not show the confidentiality row' do
        expect(rendered_content).not_to summarise(
          key: 'Can this reference be shared with the candidate?',
          value: 'No, this reference is confidential. Do not share it.',
        )
      end
    end
  end
end

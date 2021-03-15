require 'rails_helper'

RSpec.describe SupportInterface::ReferenceWithFeedbackComponent do
  describe 'Cancel and reinstate links' do
    it 'Cancel link is present when the reference is feedback_requested' do
      reference = create(:reference, feedback_status: 'feedback_requested')

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference, reference_number: 1))

      expect(rendered_component).to include('Cancel reference')
      expect(rendered_component).not_to include('Undo refusal')
    end

    it '"Undo refusal" link is present when the reference is refused' do
      reference = create(:reference, feedback_status: 'feedback_refused')

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference, reference_number: 1))

      expect(rendered_component).to include('Undo refusal')
      expect(rendered_component).not_to include('Cancel reference')
    end
  end

  describe 'title' do
    it 'includes the supplied reference number' do
      reference = create(:reference)

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference, reference_number: 1))

      expect(rendered_component).to include('1st reference')
    end

    it 'says if the reference is a replacement' do
      reference = create(:reference, replacement: true)

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference, reference_number: 1))

      expect(rendered_component).to include('(replacement)')
    end

    it 'includes the id of the reference' do
      reference = create(:reference)

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference, reference_number: 1))

      expect(rendered_component).to include("##{reference.id}")
    end
  end
end

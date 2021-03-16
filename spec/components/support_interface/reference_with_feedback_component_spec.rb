require 'rails_helper'

RSpec.describe SupportInterface::ReferenceWithFeedbackComponent do
  describe 'Undo refusal link' do
    it 'is present when the reference is refused' do
      reference = create(:reference, feedback_status: 'feedback_refused')

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference, reference_number: 1))

      expect(rendered_component).to include('Undo refusal')
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

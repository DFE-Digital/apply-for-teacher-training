require 'rails_helper'

RSpec.describe SupportInterface::ReferenceWithFeedbackComponent do
  describe 'Cancel link' do
    it 'is included when the reference is not cancelled' do
      reference = build_stubbed(:reference, feedback_status: 'feedback_requested')

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference))

      expect(rendered_component).to include('Cancel reference')
    end

    it 'is not included when the reference is cancelled' do
      reference = build_stubbed(:reference, feedback_status: 'cancelled')

      render_inline(SupportInterface::ReferenceWithFeedbackComponent.new(reference: reference))

      expect(rendered_component).not_to include('Cancel reference')
    end
  end
end

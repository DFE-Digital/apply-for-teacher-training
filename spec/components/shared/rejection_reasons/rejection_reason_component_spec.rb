require 'rails_helper'

RSpec.describe RejectionReasons::RejectionReasonComponent do
  it 'renders rejection reason' do
    rejection_reason = 'The course became full'
    application_choice = create(:application_choice, :rejected, rejection_reason:)
    result = render_inline(described_class.new(application_choice:))

    expect(result.text.chomp).to eq(rejection_reason)
  end
end

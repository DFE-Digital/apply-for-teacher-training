require 'rails_helper'

RSpec.describe SupportInterface::CourseDetailsComponent do
  it 'renders the accredited provider if present' do
    accredited_provider = create(:provider, name: 'ACCREDITED BODY NAME')

    result_with_accredited_body = render_inline(
      described_class.new(course: build_stubbed(:course, accredited_provider: accredited_provider)),
    )

    expect(result_with_accredited_body.text).to include('ACCREDITED BODY NAME')
  end
end

require 'rails_helper'

RSpec.describe SupportInterface::CourseDetailsComponent do
  it 'renders the accredited provider if present' do
    accredited_provider = create(:provider, name: 'ACCREDITED BODY NAME')

    result_with_accredited_body = render_inline(
      described_class.new(course: build_stubbed(:course, accredited_provider: accredited_provider)),
    )

    expect(result_with_accredited_body.text).to include('ACCREDITED BODY NAME')
  end

  it 'renders qualifications if possible' do
    course_with_qualifications = create(:course, qualifications: ['qts', 'pgce'])
    course_without_qualifications = create(:course, qualifications: nil)

    result_with_qualifications = render_inline(
      described_class.new(course: course_with_qualifications),
    )

    expect(result_with_qualifications.text).to include('QTS and PGCE')

    expect {
      render_inline(
        described_class.new(course: course_without_qualifications),
      )
    }.not_to raise_error
  end
end

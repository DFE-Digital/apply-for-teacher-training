require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationReviewComponent do
  it 'displays award year, qualification type and grade' do
    application_form = build :application_form
    @qualification = application_qualification = build(
      :application_qualification,
      application_form: application_form,
      qualification_type: 'GCSE',
      level: 'gcse',
      grade: 'c',
    )
    result = render_inline(
      described_class.new(application_form: application_form, application_qualification: application_qualification, subject: 'maths'),
    )

    expect(result.text).to match(/Qualification\s+GCSE/)
    expect(result.text).to match(/Year awarded\s+#{@qualification.award_year}/)
    expect(result.text).to match(/Grade\s+#{@qualification.grade.upcase}/)
  end
end

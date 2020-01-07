require 'rails_helper'

RSpec.describe QualificationRowComponent do
  it 'renders a qualification table row' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'BSc',
      subject: 'Psychology',
      award_year: '2018',
      grade: :upper_second,
    )

    result = render_inline(described_class, qualification: qualification)

    expect(result.text).to include('BSc Psychology')
    expect(result.text).to include('2018')
    expect(result.text).to include('2:1')
  end

  it 'renders a qualification with a predicted grade' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'MEng',
      subject: 'Engineering',
      award_year: '2020',
      grade: :first,
      predicted_grade: true,
    )

    result = render_inline(described_class, qualification: qualification)

    expect(result.text).to include('MEng Engineering')
    expect(result.text).to include('2020')
    expect(result.text).to include('First (predicted)')
  end

  it 'renders a qualification with a free text grade' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'BSc',
      subject: 'Chemistry',
      award_year: '2001',
      grade: 'I did my best',
    )

    result = render_inline(described_class, qualification: qualification)

    expect(result.text).to include('BSc Chemistry')
    expect(result.text).to include('2001')
    expect(result.text).to include('I did my best')
  end

  it 'renders a qualification with a missing_explanation' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'missing',
      subject: 'Maths',
      grade: nil,
      award_year: nil,
      missing_explanation: 'I am taking the exam this summer',
    )

    result = render_inline(described_class, qualification: qualification)

    expect(result.text).to include('GCSE Maths')
    expect(result.text).to include('I am taking the exam this summer')
  end
end

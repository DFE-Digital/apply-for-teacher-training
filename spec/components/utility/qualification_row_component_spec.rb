require 'rails_helper'

RSpec.describe QualificationRowComponent do
  it 'renders a qualification table row' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'BSc',
      subject: 'Psychology',
      start_year: '2015',
      award_year: '2018',
      grade: 'Upper second',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.gsub(/\s+/, ' ')).to include('Psychology BSc')
    expect(result.text).not_to include('2015')
    expect(result.text).to include('2018')
    expect(result.text).to include('Upper second')
  end

  it 'renders a qualification with a predicted grade' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'MEng',
      subject: 'Engineering',
      start_year: '2017',
      award_year: '2020',
      grade: 'First',
      predicted_grade: true,
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.gsub(/\s+/, ' ')).to include('Engineering MEng')
    expect(result.text).to include('2020')
    expect(result.text).to include('First (predicted)')
  end

  it 'renders a qualification with a free text grade' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'BSc',
      subject: 'Chemistry',
      start_year: '1998',
      award_year: '2001',
      grade: 'I did my best',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.gsub(/\s+/, ' ')).to include('Chemistry BSc')
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

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.gsub(/\s+/, ' ')).to include('Maths GCSE')
    expect(result.text).to include('I am taking the exam this summer')
  end
end

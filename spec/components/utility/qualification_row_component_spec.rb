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

    expect(result.css('td')[0].text).to include('BSc')
    expect(result.css('td')[1].text).to include('Psychology')
    expect(result.css('td')[3].text).to include('2018')
    expect(result.css('td')[4].text).to include('Upper second')
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

    expect(result.css('td')[0].text).to include('MEng')
    expect(result.css('td')[1].text).to include('Engineering')
    expect(result.css('td')[3].text).to include('2020')
    expect(result.css('td')[4].text).to include('First (predicted)')
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

    expect(result.css('td')[0].text).to include('BSc')
    expect(result.css('td')[1].text).to include('Chemistry')
    expect(result.css('td')[2].text).to include('United Kingdom')
    expect(result.css('td')[3].text).to include('2001')
    expect(result.css('td')[4].text).to include('I did my best')
  end

  it 'renders a qualification with a not_completed_explanation' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'missing',
      subject: 'Maths',
      grade: nil,
      award_year: nil,
      not_completed_explanation: 'I am taking the exam this summer',
      predicted_grade: nil,
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.css('td')[0].text).to include('GCSE')
    expect(result.css('td')[1].text).to include('Maths')
    expect(result.css('td')[4].text).to include('Not entered')
  end
end

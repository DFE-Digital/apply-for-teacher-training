require 'rails_helper'

RSpec.describe QualificationTitleComponent do
  it 'renders the correct title for a degree' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'BSc',
      subject: 'Psychology',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text).to include('BSc')
  end

  it 'renders the correct title for a degree with HESA degree type data' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'BA with intercalated PGCE',
      qualification_type_hesa_code: 12,
      subject: 'Psychology',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text).to include('BA with intercalated PGCE')
    expect(result.text).to include('(12)')
  end

  it 'renders the correct title for a GCSE' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'gcse',
      subject: 'english',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text).to include('GCSE')
  end

  it 'renders the correct title for an other_uk GCSE equivalent' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'other_uk',
      subject: 'maths',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text).to include('Other UK')
  end

  it 'renders the correct title for an other_uk GCSE equivalent with a specified type' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'other_uk',
      subject: 'maths',
      other_uk_qualification_type: 'A Level',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.strip).to eq('A Level')
  end

  it 'renders the correct title for an non_uk GCSE equivalent' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'non_uk',
      subject: 'maths',
      non_uk_qualification_type: 'High School Diploma ',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.strip).to eq('High School Diploma')
  end

  it 'renders the correct title for an other qualification' do
    qualification = build_stubbed(
      :application_qualification,
      level: :other,
      qualification_type: 'A Level',
      subject: 'History',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.strip).to eq('A Level')
  end

  it 'renders the correct title for an other_uk other qualification' do
    qualification = build_stubbed(
      :application_qualification,
      level: :other,
      qualification_type: 'other_uk',
      subject: 'Maps and stuff',
      other_uk_qualification_type: 'Orienteering',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.strip).to eq('Orienteering')
  end

  it 'renders the correct title for an non_uk other qualification' do
    qualification = build_stubbed(
      :application_qualification,
      level: :other,
      qualification_type: 'other_uk',
      subject: 'maths',
      non_uk_qualification_type: 'High School Diploma',
    )

    result = render_inline(described_class.new(qualification: qualification))

    expect(result.text.strip).to eq('High School Diploma')
  end
end

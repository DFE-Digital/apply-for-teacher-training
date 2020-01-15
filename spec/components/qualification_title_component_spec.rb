require 'rails_helper'

RSpec.describe QualificationTitleComponent do
  it 'renders the correct title for a degree' do
    qualification = build_stubbed(
      :application_qualification,
      level: :degree,
      qualification_type: 'BSc',
      subject: 'Psychology',
    )

    result = render_inline(described_class, qualification: qualification)

    expect(result.text).to include('BSc Psychology')
  end

  it 'renders the correct title for a GCSE' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'gcse',
      subject: 'english',
    )

    result = render_inline(described_class, qualification: qualification)

    expect(result.text).to include('GCSE English')
  end

  it 'renders the correct title for an other_uk GCSE equivalent' do
    qualification = build_stubbed(
      :application_qualification,
      level: :gcse,
      qualification_type: 'other_uk',
      subject: 'maths',
    )

    result = render_inline(described_class, qualification: qualification)

    expect(result.text).to include('Other UK Maths')
  end
end

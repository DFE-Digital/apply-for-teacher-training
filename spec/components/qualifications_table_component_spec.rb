require 'rails_helper'

RSpec.describe QualificationsTableComponent do
  it 'renders nothing when no qualifications present' do
    result = render_inline(described_class.new(qualifications: [], header: 'My header'))

    expect(result.css('table')).to be_blank
  end

  it 'renders a qualifications table' do
    qualifications = [
      build_stubbed(
        :application_qualification,
        level: 'degree',
        qualification_type: 'BSc',
        subject: 'Rocket Surgery',
        grade: 'Third',
        award_year: '2020',
      ),
    ]
    result = render_inline(described_class.new(qualifications: qualifications, header: 'My header'))

    expect(result.css('table').first['data-qa']).to eq 'qualifications-table-my-header'
    expect(result.css('table thead tr')[0].text.gsub(/\s+/, ' ')).to include('Qualification Awarded Grade')
    expect(result.css('table tbody tr')[0].text.gsub(/\s+/, ' ')).to include('Rocket Surgery BSc 2020 Third')
  end
end

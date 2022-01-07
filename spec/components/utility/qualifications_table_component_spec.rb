require 'rails_helper'

RSpec.describe QualificationsTableComponent do
  it 'renders nothing when no qualifications present' do
    result = render_inline(described_class.new(qualifications: [], header: 'My header', subheader: 'My subheader'))

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
    result = render_inline(described_class.new(qualifications: qualifications, header: 'My header', subheader: 'My subheader'))

    expect(result.css('table').first['data-qa']).to eq 'qualifications-table-my-header'
    expect(result.css('table thead th')[0].text).to include('Qualification')
    expect(result.css('thead tr th')[1].text).to include('Subject')
    expect(result.css('thead tr th')[2].text).to include('Country')
    expect(result.css('thead tr th')[3].text).to include('Year awarded')
    expect(result.css('thead tr th')[4].text).to include('Grade')

    expect(result.css('tbody td')[0].text).to include('BSc')
    expect(result.css('tbody td')[1].text).to include('Rocket Surgery')
    expect(result.css('tbody td')[2].text).to include('United Kingdom')
    expect(result.css('tbody td')[3].text).to include('2020')
    expect(result.css('tbody td')[4].text).to include('Third')
  end
end

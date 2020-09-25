require 'rails_helper'

RSpec.describe QualificationsTableComponent do
  it 'renders nothing when no qualifications present' do
    result = render_inline(described_class.new(qualifications: [], header: 'My header'))

    expect(result.css('table')).to be_blank
  end

  it 'renders a qualifications table' do
    qualifications = [
      build_stubbed(:application_qualification),
    ]
    result = render_inline(described_class.new(qualifications: qualifications, header: 'My header'))

    expect(result.css('table').first['data-qa']).to eq 'qualifications-table-my-header'
  end
end

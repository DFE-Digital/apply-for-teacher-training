require 'rails_helper'

RSpec.describe ProviderInterface::QualificationsTableComponent do
  it 'renders nothing when no qualifications present' do
    result = render_inline(described_class, qualifications: [], type_label: 'My label')

    expect(result.to_s).to be_blank
  end

  it 'renders a qualifications table' do
    qualifications = [
      build_stubbed(:application_qualification),
    ]
    result = render_inline(described_class, qualifications: qualifications, type_label: 'My label')

    expect(result.css('th').text).to include('My label')
  end
end

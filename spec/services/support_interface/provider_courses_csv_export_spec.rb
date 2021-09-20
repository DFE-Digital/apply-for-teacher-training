require 'rails_helper'

RSpec.describe SupportInterface::ProviderCoursesCSVExport do
  include CourseOptionHelpers

  let(:provider) { create(:provider) }

  subject(:csv_rows) { described_class.new(provider: provider).rows }

  it 'returns self-ratified courses' do
    course_option_for_provider(provider: provider)
    expect(csv_rows.count).to eq 1
  end

  it 'returns ratified courses' do
    course_option_for_accredited_provider(provider: create(:provider, name: 'SD', provider_type: 'lead_school'), accredited_provider: provider)
    expect(csv_rows.count).to eq 1
  end
end

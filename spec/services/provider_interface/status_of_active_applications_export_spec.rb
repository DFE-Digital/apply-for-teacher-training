require 'rails_helper'
RSpec.describe ProviderInterface::StatusOfActiveApplicationsExport do
  let(:provider) { create(:provider) }
  let(:other_provider) { create(:provider) }
  let(:course_without_accredited_provider) { create(:course, name: 'Beekeeping', provider: provider, accredited_provider: nil) }
  let(:course_option_without_accredited_provider) { create(:course_option, course: course_without_accredited_provider) }
  let(:course_with_other_accredited_provider) { create(:course, name: 'Archaeology', provider: provider, accredited_provider: other_provider) }
  let(:course_option_with_other_accredited_provider) { create(:course_option, course: course_with_other_accredited_provider) }
  let(:course_provider_accredits) { create(:course, name: 'Criminology', provider: other_provider, accredited_provider: provider) }
  let(:course_option_provider_accredits) { create(:course_option, course: course_provider_accredits) }

  subject(:status_of_active_applications_export) { described_class.new(provider: provider).call }

  before do
    create_list(:application_choice, 10, status: :interviewing, course_option: course_option_with_other_accredited_provider)
    create_list(:application_choice, 5, status: :pending_conditions, course_option: course_option_with_other_accredited_provider)
    create_list(:application_choice, 8, status: :interviewing, course_option: course_option_without_accredited_provider)
    create_list(:application_choice, 3, status: :pending_conditions, course_option: course_option_without_accredited_provider)
    create_list(:application_choice, 4, status: :recruited, course_option: course_option_provider_accredits)
    create_list(:application_choice, 6, status: :offer, course_option: course_option_provider_accredits)
  end

  describe '#call' do
    it 'outputs the rows in the correct format' do
      parsed_data = CSV.parse(status_of_active_applications_export, headers: true)
      row = parsed_data.first
      expect(row['name']).to eq(course_with_other_accredited_provider.name)
      expect(row['code']).to eq(course_with_other_accredited_provider.code)
      expect(row['partner_organisation']).to eq(course_with_other_accredited_provider.accredited_provider.name)
      expect(row['received']).to eq('0')
      expect(row['interviewing']).to eq('10')
      expect(row['offered']).to eq('0')
      expect(row['awaiting_conditions']).to eq('5')
      expect(row['pending_conditions']).to eq('0')
    end

    it 'outputs one row per course' do
      parsed_data = CSV.parse(status_of_active_applications_export, headers: true)
      expect(parsed_data.count).to eq(4)
    end

    it 'outputs the total of each column' do
      parsed_data = CSV.parse(status_of_active_applications_export)
      p parsed_data.last
      expect(parsed_data.last[0]).to eq('All courses')
      expect(parsed_data.last[1]).to eq('TOTAL')
      expect(parsed_data.last[2]).to eq('')
      expect(parsed_data.last[3]).to eq('0')
      expect(parsed_data.last[4]).to eq('18')
      expect(parsed_data.last[5]).to eq('6')
      expect(parsed_data.last[6]).to eq('8')
      expect(parsed_data.last[7]).to eq('4')
    end
  end
end

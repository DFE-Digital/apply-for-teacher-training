require 'rails_helper'

RSpec.describe ProviderInterface::ActiveApplicationStatusesByProvider do
  describe '#call' do
    let(:provider) { create(:provider) }
    let(:other_provider) { create(:provider) }
    let(:course_without_accredited_provider) { create(:course, name: 'Beekeeping', provider: provider, accredited_provider: nil) }
    let(:course_option_without_accredited_provider) { create(:course_option, course: course_without_accredited_provider) }
    let(:course_with_other_accredited_provider) { create(:course, name: 'Archaeology', provider: provider, accredited_provider: other_provider) }
    let(:course_option_with_other_accredited_provider) { create(:course_option, course: course_with_other_accredited_provider) }
    let(:course_provider_accredits) { create(:course, name: 'Criminology', provider: other_provider, accredited_provider: provider) }
    let(:course_option_provider_accredits) { create(:course_option, course: course_provider_accredits) }

    before do
      create_list(:application_choice, 10, status: :interviewing, course_option: course_option_with_other_accredited_provider)
      create_list(:application_choice, 5, status: :pending_conditions, course_option: course_option_with_other_accredited_provider)
      create_list(:application_choice, 8, status: :interviewing, course_option: course_option_without_accredited_provider)
      create_list(:application_choice, 3, status: :pending_conditions, course_option: course_option_without_accredited_provider)
      create_list(:application_choice, 4, status: :recruited, course_option: course_option_provider_accredits)
      create_list(:application_choice, 6, status: :offer, course_option: course_option_provider_accredits)
    end

    it 'outputs the correct course names' do
      output = described_class.new(provider).call
      expect(output[0][:header]).to eq(course_with_other_accredited_provider.name_and_code)
      expect(output[1][:header]).to eq(course_without_accredited_provider.name_and_code)
      expect(output[2][:header]).to eq(course_provider_accredits.name_and_code)
    end

    it 'outputs the correct provider names' do
      output = described_class.new(provider).call
      expect(output[0][:subheader]).to eq(course_with_other_accredited_provider.accredited_provider.name)
      expect(output[1][:subheader]).to eq(course_without_accredited_provider.provider.name)
      expect(output[2][:subheader]).to eq(course_provider_accredits.provider.name)
    end

    it 'outputs the correct status count values' do
      output = described_class.new(provider).call
      expect(output[0][:values]).to eq([0, 10, 0, 5, 0])
      expect(output[1][:values]).to eq([0, 8, 0, 3, 0])
      expect(output[2][:values]).to eq([0, 0, 6, 0, 4])
    end
  end
end

require 'rails_helper'

RSpec.describe FindApplicationChoicesWithOutOfDateProviderIds do
  let!(:application_choices) { create_list(:application_choice, 3) }

  describe '#call' do
    it 'returns an empty set if no out-of-date provider_ids are found' do
      expect(described_class.call).to be_empty
    end

    it 'returns application choices with empty provider_ids' do
      empty_ids = application_choices.second
      empty_ids.update(provider_ids: [])
      expect(described_class.call).to eq([empty_ids])
    end

    it 'returns application choices with wrong provider_ids' do
      wrong_ids = application_choices.second
      wrong_ids.update(provider_ids: [123456])
      expect(described_class.call).to eq([wrong_ids])
    end

    it 'does not mind if provider_ids are in a different order' do
      accredited_course = create(:course, :with_accredited_provider)
      accredited_option = create(:course_option, course: accredited_course)
      reverse_ids = create(:application_choice, course_option: accredited_option)
      reverse_ids.update(provider_ids: reverse_ids.provider_ids.reverse)
      expect(described_class.call).to be_empty
    end
  end
end

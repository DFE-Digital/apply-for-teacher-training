require 'rails_helper'

RSpec.describe CandidateInterface::PickProviderForm do
  describe '#available_providers' do
    it 'returns all providers' do
      create(:provider, name: 'School without courses')
      create(:course, open_on_apply: false, exposed_in_find: false, provider: create(:provider, name: 'School with disabled courses'))
      create(:course, open_on_apply: true, exposed_in_find: true, provider: create(:provider, name: 'School with courses'))

      form = described_class.new({})

      expect(form.available_providers.map(&:name)).to eql(['School with courses', 'School with disabled courses', 'School without courses'])
    end
  end

  describe '#courses_available?' do
    it 'returns false if there are no exposed courses matched by provider id in the current cycle' do
      unexposed_course = create(:course, exposed_in_find: false)
      provider = unexposed_course.provider
      create(:course, exposed_in_find: true, recruitment_cycle_year: RecruitmentCycle.previous_year, provider: unexposed_course.provider)

      form = described_class.new(provider_id: provider.id)

      expect(form.courses_available?).to eq false
    end

    it 'returns true if there are exposed courses matched by provider id' do
      exposed_course = create(:course, exposed_in_find: true)
      provider = exposed_course.provider

      form = described_class.new(provider_id: provider.id)

      expect(form.courses_available?).to eq true
    end
  end
end

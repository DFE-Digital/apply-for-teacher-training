require 'rails_helper'

RSpec.describe CandidateInterface::PickProviderForm do
  describe '#available_providers' do
    it 'returns providers with a course exposed in find in the current cycle which are open on apply' do
      create(:provider, name: 'School without courses')
      create(:course, :open_on_apply, exposed_in_find: false, provider: create(:provider, name: 'School with disabled courses'))
      create(:course, :open_on_apply, opened_on_apply_at: Time.zone.today, provider: create(:provider, name: 'School with courses'))
      create(:course, :open_on_apply, opened_on_apply_at: Time.zone.tomorrow, provider: create(:provider, name: 'School with courses but not open for applications'))
      create(:course, :open_on_apply, recruitment_cycle_year: RecruitmentCycle.previous_year)

      form = described_class.new({})

      expect(form.available_providers.map(&:name)).to eq(['School with courses'])
    end
  end
end

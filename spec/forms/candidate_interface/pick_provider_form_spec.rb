require 'rails_helper'

RSpec.describe CandidateInterface::PickProviderForm do
  describe '#available_providers' do
    it 'returns providers with a course exposed in find in the current cycle' do
      create(:provider, name: 'School without courses')
      create(:course, :open, exposed_in_find: false, provider: create(:provider, name: 'School with disabled courses'))
      create(:course, :open, exposed_in_find: true, recruitment_cycle_year: current_year, provider: create(:provider, name: 'School with courses'))
      create(:course, :open, exposed_in_find: true, recruitment_cycle_year: current_year, provider: create(:provider, name: 'School with courses but not open for applications'))
      create(:course, :open, exposed_in_find: true, recruitment_cycle_year: previous_year)
      create(:course, :open, exposed_in_find: true, recruitment_cycle_year: next_year)

      form = described_class.new({})

      expect(form.available_providers.map(&:name)).to eq(['School with courses', 'School with courses but not open for applications'])
    end
  end
end

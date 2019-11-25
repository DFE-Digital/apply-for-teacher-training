require 'rails_helper'

RSpec.describe CandidateInterface::PickProviderForm do
  describe '#available_providers' do
    it 'returns providers with available courses' do
      create(:provider, name: 'School without courses')
      create(:course, open_on_apply: false, exposed_in_find: true, provider: create(:provider, name: 'School with disabled courses'))
      create(:course, open_on_apply: true, exposed_in_find: true, provider: create(:provider, name: 'School with courses'))

      form = CandidateInterface::PickProviderForm.new({})

      expect(form.available_providers.map(&:name)).to eql(['School with courses'])
    end
  end
end

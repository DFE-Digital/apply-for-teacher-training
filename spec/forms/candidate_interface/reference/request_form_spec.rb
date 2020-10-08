require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RequestForm, type: :model do
  describe '.build_from_reference' do
    it 'creates an object based on the reference' do
      application_reference = build_stubbed(:reference, name: 'Walter White')
      form = described_class.build_from_reference(application_reference)

      expect(form.referee_name).to eq('Walter White')
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:request_now) }
  end
end

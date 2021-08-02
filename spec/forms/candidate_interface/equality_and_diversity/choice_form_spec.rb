require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::ChoiceForm, type: :model do
  describe '#initialize' do
    it 'defaults to yes' do
      form = described_class.new

      expect(form.choice).to eq('yes')
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:choice) }
  end
end

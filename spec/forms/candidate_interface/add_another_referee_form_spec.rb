require 'rails_helper'

RSpec.describe CandidateInterface::AddAnotherRefereeForm, type: :model do
  let(:form) { described_class.new(add_another_referee) }
  let(:add_another_referee) do
    { 'add_another_referee' => 'yes' }
  end

  it { is_expected.to validate_presence_of(:add_another_referee) }

  describe '#add_another_referee?' do
    context 'when the add_another_referee value is yes' do
      it 'returns true' do
        expect(form.add_another_referee?).to be_truthy
      end
    end

    context 'when the add_another_referee value is no' do
      let(:add_another_referee) do
        { 'add_another_referee' => 'no' }
      end

      it 'returns false' do
        expect(form.add_another_referee?).to be_falsey
      end
    end
  end
end

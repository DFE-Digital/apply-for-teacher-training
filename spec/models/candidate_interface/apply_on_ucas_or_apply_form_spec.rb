require 'rails_helper'

RSpec.describe CandidateInterface::ApplyOnUcasOrApplyForm, type: :model do
  it { is_expected.to validate_presence_of(:service) }

  describe '#ucas?' do
    context 'when service is ucas' do
      it 'returns true' do
        form = CandidateInterface::ApplyOnUcasOrApplyForm.new(service: 'ucas')

        expect(form.ucas?).to eq(true)
      end
    end

    context 'when service is apply' do
      it 'returns false' do
        form = CandidateInterface::ApplyOnUcasOrApplyForm.new(service: 'apply')

        expect(form.ucas?).to eq(false)
      end
    end
  end
end

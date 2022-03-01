require 'rails_helper'

RSpec.describe RefereeInterface::RefuseFeedbackForm do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:refused) }

    describe '#save' do
      let(:application_reference) { create(:reference, :feedback_requested) }

      context 'when the form is invalid' do
        it 'returns false' do
          form = described_class.new

          expect(form.save(application_reference)).to be(false)
        end
      end

      context 'when the form is valid and the reference was refused' do
        it 'updates the reference refused status' do
          form = described_class.new(refused: 'yes')
          form.save(application_reference)

          expect(application_reference.refused).to be(true)
        end
      end

      context 'when the form is valid and the reference was not refused' do
        it 'updates the reference refused status' do
          form = described_class.new(refused: 'no')
          form.save(application_reference)

          expect(application_reference.refused).to be(false)
        end
      end
    end
  end
end

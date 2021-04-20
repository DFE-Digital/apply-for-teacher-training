require 'rails_helper'
RSpec.describe OfferValidations, type: :model do
  subject(:offer) { OfferValidations.new(course_option: course_option) }

  let(:course_option) { create(:course_option, course: course) }
  let(:course) { create(:course, :open_on_apply) }

  context 'validations' do
    it { is_expected.to validate_presence_of(:course_option) }

    describe '#course_option_open_on_apply' do
      context 'when no course_option' do
        let(:course_option) { nil }

        it 'does not add a :not_open_on_apply error' do
          offer.valid?

          expect(offer.errors[:course_option]).not_to contain_exactly('is not open for applications via the Apply service')
        end
      end

      context 'when not open on apply' do
        let(:course) { create(:course, :ucas_only) }

        it 'adds a :not_open_on_apply error' do
          expect(offer).to be_invalid

          expect(offer.errors[:course_option]).to contain_exactly('The requested course is not open for applications via the Apply service')
        end
      end
    end
  end
end

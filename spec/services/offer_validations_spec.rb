require 'rails_helper'
RSpec.describe OfferValidations, type: :model do
  subject(:offer) { OfferValidations.new(application_choice: application_choice, course_option: course_option, conditions: conditions) }

  let(:application_choice) { nil }
  let(:course_option) { create(:course_option, course: course) }
  let(:course) { create(:course, :open_on_apply) }
  let(:conditions) { [] }

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

    describe '#conditions_count' do
      context 'when more than MAX_CONDITIONS_COUNT' do
        let(:conditions) { (OfferValidations::MAX_CONDITIONS_COUNT + 1).times.map { Faker::Coffee.blend_name } }

        it 'adds a :too_many error' do
          expect(offer).to be_invalid

          expect(offer.errors[:conditions]).to contain_exactly("Offer has over #{OfferValidations::MAX_CONDITIONS_COUNT} conditions")
        end
      end
    end

    describe '#conditions_length' do
      context 'when any conditions after condition 1 are more than 255 characters long' do
        let(:conditions) do
          [Faker::Lorem.paragraph_by_chars(number: 256),
           Faker::Lorem.paragraph_by_chars(number: 254),
           Faker::Lorem.paragraph_by_chars(number: 256)]
        end

        it 'adds a :too_long error' do
          expect(offer).to be_invalid

          expect(offer.errors[:conditions]).to contain_exactly('Condition 3 must be 255 characters or fewer')
        end
      end

      context 'when conditions are merged into condition 1 in the API' do
        let(:conditions) do
          [Faker::Lorem.paragraph_by_chars(number: 2004),
           Faker::Lorem.paragraph_by_chars(number: 254),
           Faker::Lorem.paragraph_by_chars(number: 256)]
        end

        it 'adds a :too_long error' do
          expect(offer).to be_invalid

          expect(offer.errors[:conditions]).to contain_exactly('Condition 1 must be 2000 characters or fewer', 'Condition 3 must be 255 characters or fewer')
        end
      end
    end

    describe '#identical_to_existing_offer?' do
      context 'when the offer details are identical to the existing offer' do
        let(:application_choice) { build_stubbed(:application_choice, :with_offer) }
        let(:course_option) { application_choice.course_option }
        let(:conditions) { application_choice.offer.conditions_text }

        it 'raises an IdenticalOfferError' do
          expect { offer.valid? }.to raise_error(IdenticalOfferError)
        end
      end
    end

    describe '#ratifying_provider_changed?' do
      context 'when the ratifying provider is different than the one of the requested course' do
        let(:application_choice) { build_stubbed(:application_choice, :with_offer, current_course_option: current_course_option) }
        let(:current_course_option) { create(:course_option, :open_on_apply) }
        let(:course_option) { build(:course_option, :open_on_apply) }
        let(:conditions) { application_choice.offer.conditions_text }

        it 'adds a :different_ratifying_provider error' do
          expect(offer).to be_invalid

          expect(offer.errors[:base]).to contain_exactly('The offered course\'s ratifying provider must be the same as the one originally requested')
        end
      end
    end
  end
end

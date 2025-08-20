require 'rails_helper'
RSpec.describe OfferValidations, type: :model do
  subject(:offer) { described_class.new(application_choice:, course_option:, conditions:) }

  let(:application_choice) { nil }
  let(:course_option) { create(:course_option, course:) }
  let(:course) { create(:course) }
  let(:conditions) { [] }

  context 'validations' do
    it { is_expected.to validate_presence_of(:course_option) }

    describe '#conditions_count' do
      context 'when more than MAX_CONDITIONS_COUNT' do
        let(:conditions) { (OfferValidations::MAX_CONDITIONS_COUNT + 1).times.map { Faker::Coffee.blend_name } }

        it 'adds a :too_many error' do
          expect(offer).not_to be_valid

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
          expect(offer).not_to be_valid

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
          expect(offer).not_to be_valid

          expect(offer.errors[:conditions]).to contain_exactly('Condition 1 must be 2000 characters or fewer', 'Condition 3 must be 255 characters or fewer')
        end
      end
    end

    describe '#identical_to_existing_offer?' do
      context 'when the offer details are identical to the existing offer' do
        let(:application_choice) { build_stubbed(:application_choice, :offered) }
        let(:course_option) { application_choice.course_option }
        let(:conditions) { application_choice.offer.all_conditions_text }

        it 'raises an IdenticalOfferError' do
          expect { offer.valid? }.to raise_error(IdenticalOfferError)
        end
      end

      context 'when the offer details differ only by reference condition' do
        let(:candidate) { create(:candidate) }
        let(:current_course_option) { create(:course_option) }
        let(:application_choice) { create(:application_choice, :offered, current_course_option:, candidate:) }
        let(:course_option) { application_choice.course_option }
        let(:conditions) { application_choice.offer.all_conditions_text }
        let(:reference_condition) { build(:reference_condition) }
        let(:new_reference_condition) { build(:reference_condition, required: false) }

        subject(:offer) { described_class.new(application_choice:, course_option:, conditions:, structured_conditions: [new_reference_condition]) }

        it 'does not raise an IdenticalOfferError' do
          allow(application_choice.offer).to receive(:reference_condition).and_return(reference_condition)
          expect { offer.valid? }.not_to raise_error
        end
      end

      context 'when the offer details differ only by SKE condition' do
        let(:candidate) { create(:candidate) }
        let(:current_course_option) { create(:course_option) }
        let(:application_choice) { create(:application_choice, :offered, current_course_option:, candidate:) }
        let(:course_option) { application_choice.course_option }
        let(:conditions) { application_choice.offer.all_conditions_text }
        let(:ske_conditions) { [build(:ske_condition)] }
        let(:new_ske_conditions) { [build(:ske_condition, length: '8'), build(:ske_condition, length: '12')] }

        subject(:offer) { described_class.new(application_choice:, course_option:, conditions:, structured_conditions: new_ske_conditions) }

        it 'does not raise an IdenticalOfferError' do
          allow(application_choice.offer).to receive(:ske_conditions).and_return(ske_conditions)
          expect { offer.valid? }.not_to raise_error
        end
      end
    end

    describe '#ratifying_provider_changed?' do
      context 'when the ratifying provider is different than the one of the requested course' do
        let(:candidate) { create(:candidate) }
        let(:application_choice) { create(:application_choice, :offered, current_course_option:) }
        let!(:application_form) { create(:application_form, phase: 'apply_1', candidate:, application_choices: [application_choice]) }
        let(:current_course_option) { create(:course_option) }
        let(:course_option) { build(:course_option) }
        let(:conditions) { application_choice.offer.all_conditions_text }

        it 'adds a :different_ratifying_provider error' do
          expect(offer).not_to be_valid

          expect(offer.errors[:base]).to contain_exactly('The offered course\'s ratifying provider must be the same as the one originally requested')
        end
      end
    end

    describe '#restrict_reverting_rejection' do
      context 'when a provider attempts to revert an application rejected by default' do
        let(:candidate) { create(:candidate) }
        let(:application_choice) { create(:application_choice, :rejected, current_course_option: course_option, rejected_by_default: true) }
        let!(:application_form) { create(:application_form, phase: 'apply_1', application_choices: [application_choice], candidate:) }

        it 'adds an :application_rejected_by_default error' do
          expect(offer).not_to be_valid
          expect(offer.errors[:base]).to contain_exactly('You cannot make an offer because the application has been automatically rejected')
        end
      end

      context 'when a provider attempts to revert an apply_1 rejection but other offers have already been accepted' do
        let!(:application_form) { create(:application_form, application_choices: [application_choice, other_application_choice]) }
        let(:application_choice) { build(:application_choice, :offered, current_course_option: course_option) }
        let!(:other_application_choice) { build(:application_choice, :recruited) }

        it 'adds an :other_offer_already_accepted error' do
          expect(offer).not_to be_valid
          expect(offer.errors[:base]).to contain_exactly('You cannot make an offer because the candidate has already accepted one')
        end
      end

      context 'when a provider attempts to make an offer when conditions not met sibling exists' do
        let!(:application_form) { create(:application_form, application_choices: [application_choice, other_application_choice]) }
        let(:application_choice) { build(:application_choice, :offered, current_course_option: course_option) }
        let!(:other_application_choice) { build(:application_choice, :conditions_not_met) }

        it 'is valid' do
          expect(offer).to be_valid
        end
      end

      context 'when a provider attempts to revert a rejection on an application that is not the last one on apply_2' do
        let(:candidate) { create(:candidate) }
        let(:application_choice) { build(:application_choice, :rejected, current_course_option: course_option, created_at: 1.day.ago) }
        let(:other_application_choice) { build(:application_choice, :awaiting_provider_decision) }
        let!(:application_form) { create(:application_form, application_choices: [application_choice], created_at: 1.day.ago, candidate:) }
        let!(:other_application_form) { create(:application_form, application_choices: [other_application_choice], candidate:) }

        it 'adds an :only_latest_application_rejection_can_be_reverted_on_apply_2 error' do
          expect(offer).not_to be_valid
          expect(offer.errors[:base]).to contain_exactly('You cannot make an offer because you can only do so for the most recent application')
        end
      end

      context 'when a provider attempts to revert an apply_1 rejection but there is an application in apply_2' do
        let(:candidate) { create(:candidate) }
        let(:application_choice) { build(:application_choice, :rejected, current_course_option: course_option) }
        let!(:other_application_choice) { build(:application_choice, :awaiting_provider_decision) }

        let!(:application_form_apply_1) { create(:application_form, application_choices: [application_choice], candidate:) }
        let!(:application_form_apply_2) { create(:application_form, application_choices: [other_application_choice], candidate:) }

        it 'adds an :only_latest_application_rejection_can_be_reverted_on_apply_2 error' do
          expect(offer).not_to be_valid
          expect(offer.errors[:base]).to contain_exactly('You cannot make an offer because you can only do so for the most recent application')
        end
      end

      context 'when a provider attempts to revert an apply_2 rejection but there is an application in apply_1' do
        let(:candidate) { create(:candidate) }
        let(:other_application_choice) { build(:application_choice, :rejected) }
        let!(:application_choice) { build(:application_choice, :rejected, current_course_option: course_option) }

        let!(:application_form_apply_1) { create(:application_form, application_choices: [other_application_choice], candidate:) }
        let!(:application_form_apply_2) { create(:application_form, application_choices: [application_choice], candidate:) }

        it 'is valid' do
          expect(offer).to be_valid
        end
      end

      context 'when a provider attempts to revert an apply_2 rejection and there are multiple applications in apply 2' do
        let(:candidate) { create(:candidate) }
        let(:apply_1_application_choice) { build(:application_choice, :rejected, created_at: 1.week.ago) }
        let(:application_choice) { build(:application_choice, :rejected, current_course_option: course_option, created_at: 1.day.ago) }
        let(:other_application_choice) { build(:application_choice, :rejected) }

        let!(:application_form_apply_1) { create(:application_form, application_choices: [apply_1_application_choice], candidate:, created_at: 1.week.ago) }
        let!(:application_form_apply_2) { create(:application_form, application_choices: [application_choice, other_application_choice], candidate:) }

        it 'is valid' do
          expect(offer).to be_valid
        end
      end

      context 'when a provider attempts to revert an apply_2 rejection but other offers have already been accepted' do
        let(:application_choice) { build(:application_choice, :rejected, current_course_option: course_option) }
        let(:other_application_choice) { build(:application_choice, :recruited) }
        let!(:application_form) { create(:application_form, application_choices: [application_choice, other_application_choice]) }

        it 'adds an :other_offer_already_accepted error' do
          expect(offer).not_to be_valid
          expect(offer.errors[:base]).to contain_exactly('You cannot make an offer because the candidate has already accepted one')
        end
      end
    end
  end
end

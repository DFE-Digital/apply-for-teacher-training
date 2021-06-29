require 'rails_helper'

RSpec.describe Offer do
  describe 'associations' do
    it '#conditions returns the list of conditions ordered by created_at' do
      condition1 = create(:offer_condition, text: 'Do a backflip and send us a video', created_at: 1.day.ago)
      condition2 = create(:offer_condition, text: 'Provide evidence of degree qualification', created_at: 2.days.ago)
      offer = create(:offer, conditions: [condition1, condition2])

      expect(offer.conditions.reload.map(&:text)).to eq(['Provide evidence of degree qualification', 'Do a backflip and send us a video'])
    end

    describe '#course_option' do
      it 'returns the application choice current_course_option' do
        application_choice = create(:application_choice, current_course_option: create(:course_option))
        offer = create(:offer, application_choice: application_choice)

        expect(offer.course_option).to eq(application_choice.reload.current_course_option)
      end
    end
  end

  describe '#unconditional' do
    it 'returns true when there are no conditions' do
      offer = create(:unconditional_offer)

      expect(offer.unconditional?).to be true
    end
  end

  describe '#non_pending_conditions?' do
    it 'returns false when there are no conditions' do
      offer = create(:unconditional_offer)

      expect(offer.non_pending_conditions?).to be false
    end

    it 'returns false if all conditions are pending' do
      offer = create(:offer, conditions: [build(:offer_condition), build(:offer_condition)])

      expect(offer.non_pending_conditions?).to be false
    end

    it 'returns true if there is a non-pending condition' do
      offer = create(:offer, conditions: [build(:offer_condition, status: :met), build(:offer_condition)])

      expect(offer.non_pending_conditions?).to be true
    end
  end

  context 'delegators' do
    let(:offer) { create(:offer, course_option: create(:course_option)) }

    describe '#course' do
      it 'returns the course related to the course_option' do
        expect(offer.course).to eq(offer.course_option.course)
      end
    end

    describe '#site' do
      it 'returns the site related to the course_option' do
        expect(offer.site).to eq(offer.course_option.site)
      end
    end

    describe '#provider' do
      it 'returns the provider related to the course_option' do
        expect(offer.provider).to eq(offer.course_option.provider)
      end
    end

    describe '#accredited_provider' do
      it 'returns the accredited_provider related to the course_option' do
        expect(offer.accredited_provider).to eq(offer.course_option.accredited_provider)
      end
    end

    describe '#offered_at' do
      let(:application_choice) { create(:application_choice) }
      let(:offer) { create(:offer, application_choice: application_choice) }

      it 'returns the offered_at related to the application_choice' do
        expect(offer.offered_at).to eq(offer.course_option.accredited_provider)
      end
    end
  end
end

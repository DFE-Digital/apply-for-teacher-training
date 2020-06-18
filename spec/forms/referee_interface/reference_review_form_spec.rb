require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceReviewForm do
  describe 'validations' do
    let(:review_form) { described_class.new(reference: build_stubbed(:reference, :complete)) }

    it 'is valid when all questions are complete' do
      expect(review_form).to be_valid
    end

    context 'when feedback is nil' do
      before { review_form.reference.feedback = nil }

      it 'is invalid' do
        expect(review_form).not_to be_valid
        expect(review_form.errors.full_messages).to eq(
          ["Can't submit a reference without answers to all questions"],
        )
      end
    end

    context 'when safeguarding_concerns is nil' do
      before { review_form.reference.safeguarding_concerns = nil }

      it 'is invalid' do
        expect(review_form).not_to be_valid
        expect(review_form.errors.full_messages).to eq(
          ["Can't submit a reference without answers to all questions"],
        )
      end
    end

    context 'when relationship_correction is nil' do
      before { review_form.reference.relationship_correction = nil }

      it 'is invalid' do
        expect(review_form).not_to be_valid
        expect(review_form.errors.full_messages).to eq(
          ["Can't submit a reference without answers to all questions"],
        )
      end
    end
  end
end

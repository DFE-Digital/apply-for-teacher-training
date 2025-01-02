require 'rails_helper'

RSpec.describe WithdrawalReason do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:reason) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:application_choice) }
  end

  describe '#selectable_reasons' do
    it 'returns a hash of selectable reasons' do
      expect(described_class.selectable_reasons).to eq(selectable_reasons)
    end
  end

  describe '#find_reason_options' do
    context 'without a reason_id' do
      it 'returns all selectable reasons' do
        expect(described_class.find_reason_options).to eq(selectable_reasons)
      end
    end

    context 'with primary reason id' do
      it 'returns all the reasons under that id' do
        expect(
          described_class.find_reason_options('applying-to-another-provider'),
        ).to eq(selectable_reasons['applying-to-another-provider'])
      end
    end

    context 'with nested reason id' do
      it 'returns all secondary reasons when there are any' do
        expect(
          described_class.find_reason_options('applying-to-another-provider.personal-circumstances-have-changed'),
        ).to eq({ 'concerns-about-cost-of-doing-course' => {},
                  'concerns-about-having-enough-time-to-train' => {},
                  'concerns-about-training-with-a-disability-or-health-condition' => {},
                  'other' => {} })
      end

      it 'returns an empty hash when there are none' do
        expect(
          described_class.find_reason_options('applying-to-another-provider.location-is-too-far-away'),
        ).to eq({})
      end
    end
  end

private

  def selectable_reasons
    { 'applying-to-another-provider' =>
       { 'accepted-another-offer' => {},
         'seen-a-course-that-suits-me-better' => {},
         'provider-has-not-replied-to-me' => {},
         'location-is-too-far-away' => {},
         'personal-circumstances-have-changed' =>
          { 'concerns-about-cost-of-doing-course' => {},
            'concerns-about-having-enough-time-to-train' => {},
            'concerns-about-training-with-a-disability-or-health-condition' => {},
            'other' => {} },
         'course-no-longer-available' => {},
         'other' => {} },
      'change-or-update-application-with-this-provider' =>
       { 'update-my-application-correct-an-error-or-add-information' => {},
         'change-study-pattern' => {},
         'apply-for-a-different-subject-with-the-same-provider' => {},
         'other' => {} },
      'apply-in-the-future' =>
       { 'personal-circumstances-have-changed' =>
          { 'concerns-about-cost-of-doing-course' => {},
            'concerns-about-having-enough-time-to-train' => {},
            'concerns-about-training-with-a-disability-or-health-condition' => {},
            'other' => {} },
         'gain-more-experience' => {},
         'improve-qualifications' => {},
         'other' => {} },
      'do-not-want-to-train-anymore' =>
       { 'personal-circumstances-have-changed' =>
          { 'concerns-about-cost-of-doing-course' => {},
            'concerns-about-having-enough-time-to-train' => {},
            'concerns-about-training-with-a-disability-or-health-condition' => {},
            'other' => {} },
         'another-career-path-or-accepted-a-job-offer' => {},
         'other' => {} },
      'other' => {} }
  end
end

require 'rails_helper'

RSpec.describe SupportInterface::ConditionsForm do
  describe '#save' do
    it 'returns false with a validation error if audit_comment is missing' do
      application_choice = create(
        :application_choice,
        offer: { 'conditions' => ['Fitness to train to teach check', 'Get a haircut'] },
      )
      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Fitness to train to teach check',
          'Disclosure and Barring Service (DBS) check',
        ],
        'further_conditions' => {
          '0' => { 'text' => 'Get a haircut' },
          '1' => { 'text' => 'Wear a tie' },
        },
      )
      expect(form.save).to be(false)
      expect(application_choice.reload.offer['conditions']).to eq([
        'Fitness to train to teach check',
        'Get a haircut',
      ])
    end

    it 'adds an additional further and standard condition' do
      application_choice = create(
        :application_choice,
        offer: { 'conditions' => ['Fitness to train to teach check', 'Get a haircut'] },
      )
      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Fitness to train to teach check',
          'Disclosure and Barring Service (DBS) check',
        ],
        'further_conditions' => {
          '0' => { 'text' => 'Get a haircut' },
          '1' => { 'text' => 'Wear a tie' },
        },
        'audit_comment' => 'See support ticket #123',
      )
      form.save
      expect(application_choice.reload.offer).to eq(
        'conditions' => [
          'Fitness to train to teach check',
          'Disclosure and Barring Service (DBS) check',
          'Get a haircut',
          'Wear a tie',
        ],
      )
    end

    it 'can remove conditions' do
      application_choice = create(
        :application_choice,
        offer: { 'conditions' => ['Fitness to train to teach check', 'Get a haircut', 'Wear a tie'] },
      )
      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Disclosure and Barring Service (DBS) check',
        ],
        'further_conditions' => {
          '0' => { 'text' => 'Wear a tie' },
        },
        'audit_comment' => 'See support ticket #123',
      )
      form.save
      expect(application_choice.reload.offer).to eq(
        'conditions' => [
          'Disclosure and Barring Service (DBS) check',
          'Wear a tie',
        ],
      )
    end

    it 'includes an audit comment', with_audited: true do
      application_choice = create(
        :application_choice,
        offer: { 'conditions' => ['Fitness to train to teach check'] },
      )
      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Disclosure and Barring Service (DBS) check',
        ],
        'audit_comment' => 'See support ticket #123',
      )
      form.save
      expect(
        application_choice.audits.where(
          action: 'update',
          comment: 'See support ticket #123',
        ),
      ).to be_present
    end
  end

  describe '.build_from_application_choice' do
    it 'handles a missing offer value' do
      application_choice = build(:application_choice, offer: nil)
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([])
      expect(form.further_conditions).to eq(['', '', '', ''])
    end

    it 'handles an empty set of conditions' do
      application_choice = build(:application_choice, offer: { 'conditions' => [] })
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([])
      expect(form.further_conditions).to eq(['', '', '', ''])
    end

    it 'reads standard and further conditions' do
      application_choice = build(
        :application_choice,
        offer: { 'conditions' => ['Fitness to train to teach check', 'Get a haircut'] },
      )
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq(['Fitness to train to teach check'])
      expect(form.further_conditions).to eq(['Get a haircut', '', '', ''])
    end
  end
end

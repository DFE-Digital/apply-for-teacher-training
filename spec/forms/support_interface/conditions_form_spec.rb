require 'rails_helper'

RSpec.describe SupportInterface::ConditionsForm do
  describe '#validations' do
    it 'first further condition can be up to 2000 characters' do
      application_choice = create(:application_choice)
      form = described_class.build_from_params(
        application_choice,
        'further_conditions' => {
          '0' => { 'text' => 2000.times.map { ('a'..'z').to_a[rand(26)] }.join },
          '1' => { 'text' => 255.times.map { ('a'..'z').to_a[rand(26)] }.join },
        },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      expect(form).to be_valid
    end

    it 'first further condition cannot be more than 2000 characters' do
      application_choice = create(:application_choice)
      form = described_class.build_from_params(
        application_choice,
        'further_conditions' => {
          '0' => { 'text' => 2001.times.map { ('a'..'z').to_a[rand(26)] }.join },
          '1' => { 'text' => 10.times.map { ('a'..'z').to_a[rand(26)] }.join },
        },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      expect(form).not_to be_valid
      expect(form.errors.messages[:'further_conditions[0][text]']).to include('Condition 1 must be 2000 characters or fewer')
    end

    it 'second further condition cannot be more than 255 characters' do
      application_choice = create(:application_choice)
      form = described_class.build_from_params(
        application_choice,
        'further_conditions' => {
          '0' => { 'text' => 10.times.map { ('a'..'z').to_a[rand(26)] }.join },
          '1' => { 'text' => 256.times.map { ('a'..'z').to_a[rand(26)] }.join },
        },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      expect(form).not_to be_valid
      expect(form.errors.messages[:'further_conditions[1][text]']).to include('Condition 2 must be 255 characters or fewer')
    end

    it 'can have 20 further conditions' do
      application_choice = build(:application_choice)
      form = described_class.build_from_params(
        application_choice,
        'further_conditions' => (0..19).to_h { |id| [id.to_s, { 'text' => "further condition #{id}" }] },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      expect(form).to be_valid
    end

    it 'cannot have more than 20 conditions' do
      application_choice = build(:application_choice)
      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => ['Fitness to train to teach check'],
        'further_conditions' => (0..19).to_h { |id| [id.to_s, { 'text' => "further condition #{id}" }] },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      expect(form).not_to be_valid
      expect(form.errors.messages[:base]).to include('You can only have 20 conditions or fewer')
    end
  end

  describe '#save' do
    it 'returns false with a validation error if audit_comment_ticket is missing' do
      conditions = [build(:offer_condition, text: 'Fitness to train to teach check'),
                    build(:offer_condition, text: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :with_offer,
                                  offer: build(:offer, conditions:))
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
      expect(form.errors.full_messages).to include('Audit comment ticket Enter a Zendesk ticket URL')
      expect(application_choice.offer.conditions_text).to eq([
        'Fitness to train to teach check',
        'Get a haircut',
      ])
    end

    it 'adds an additional further and standard condition' do
      conditions = [build(:offer_condition, text: 'Fitness to train to teach check'),
                    build(:offer_condition, text: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :with_offer,
                                  offer: build(:offer, conditions:))
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
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      form.save

      expect(application_choice.offer.reload.conditions_text).to match_array([
        'Fitness to train to teach check',
        'Disclosure and Barring Service (DBS) check',
        'Get a haircut',
        'Wear a tie',
      ])
    end

    it 'updates the attached offer model' do
      conditions = [build(:offer_condition, text: 'Fitness to train to teach check'),
                    build(:offer_condition, text: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :with_offer,
                                  offer: build(:offer, conditions:))
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
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      form.save

      offer = Offer.find_by(application_choice:)
      expect(offer.conditions_text).to match_array(
        [
          'Fitness to train to teach check',
          'Disclosure and Barring Service (DBS) check',
          'Get a haircut',
          'Wear a tie',
        ],
      )
    end

    it 'can remove conditions' do
      conditions = [build(:offer_condition, text: 'Fitness to train to teach check'),
                    build(:offer_condition, text: 'Get a haircut'),
                    build(:offer_condition, text: 'Wear a tie')]
      application_choice = create(:application_choice,
                                  :with_offer,
                                  offer: build(:offer, conditions:))
      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Disclosure and Barring Service (DBS) check',
        ],
        'further_conditions' => {
          '0' => { 'text' => 'Wear a tie' },
        },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      form.save
      expect(application_choice.offer.reload.conditions_text).to match_array(
        [
          'Disclosure and Barring Service (DBS) check',
          'Wear a tie',
        ],
      )
    end

    it 'includes an audit comment', with_audited: true do
      application_choice = create(:application_choice, :with_offer)
      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Disclosure and Barring Service (DBS) check',
        ],
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      form.save
      expect(
        application_choice.audits.where(
          action: 'update',
          comment: 'Change offer condition Zendesk request: https://becomingateacher.zendesk.com/agent/tickets/12345',
        ),
      ).to be_present
    end
  end

  describe '.build_from_application_choice' do
    it 'handles a missing offer value' do
      application_choice = build(:application_choice, offer: nil)
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([])
      expect(form.further_condition_attrs).to eq({ '0' => { 'text' => '' } })
    end

    it 'handles an empty set of conditions' do
      application_choice = build(:application_choice, offer: build(:unconditional_offer))
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([])
      expect(form.further_condition_attrs).to eq({ '0' => { 'text' => '' } })
    end

    it 'reads standard and further conditions' do
      conditions = [build(:offer_condition, text: OfferCondition::STANDARD_CONDITIONS.sample),
                    build(:offer_condition, text: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :with_offer,
                                  offer: build(:offer, conditions:))
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([conditions.first.text])
      expect(form.further_condition_attrs).to eq({
        '0' => { 'text' => conditions.last.text, 'condition_id' => conditions.last.id },
        '1' => { 'text' => '' },
      })
    end

    it 'reads more than 4 further conditions' do
      conditions = [build(:offer_condition, text: 'Fitness to train to teach check'),
                    build(:offer_condition, text: 'FC1'),
                    build(:offer_condition, text: 'FC2'),
                    build(:offer_condition, text: 'FC3'),
                    build(:offer_condition, text: 'FC4'),
                    build(:offer_condition, text: 'FC5')]
      application_choice = create(:application_choice,
                                  :with_offer,
                                  offer: build(:offer, conditions:))
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq(['Fitness to train to teach check'])
      expect(form.further_condition_attrs.values.map { |hash| hash['text'] }).to eq(['FC1', 'FC2', 'FC3', 'FC4', 'FC5', ''])
    end
  end
end

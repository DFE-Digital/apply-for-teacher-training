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
      conditions = [build(:text_condition, description: 'Fitness to train to teach check'),
                    build(:text_condition, description: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :offered,
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
      expect(application_choice.offer.all_conditions_text).to eq([
        'Fitness to train to teach check',
        'Get a haircut',
      ])
    end

    it 'adds an additional further and standard condition' do
      conditions = [build(:text_condition, description: 'Fitness to train to teach check'),
                    build(:text_condition, description: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :offered,
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

      expect(application_choice.offer.reload.all_conditions_text).to contain_exactly(
        'Fitness to train to teach check',
        'Disclosure and Barring Service (DBS) check',
        'Get a haircut',
        'Wear a tie',
      )
    end

    it 'updates the attached offer model' do
      conditions = [build(:text_condition, description: 'Fitness to train to teach check'),
                    build(:text_condition, description: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :offered,
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
      expect(offer.all_conditions_text).to contain_exactly(
        'Fitness to train to teach check',
        'Disclosure and Barring Service (DBS) check',
        'Get a haircut',
        'Wear a tie',
      )
    end

    it 'can remove conditions' do
      conditions = [build(:text_condition, description: 'Fitness to train to teach check'),
                    build(:text_condition, description: 'Get a haircut'),
                    build(:text_condition, description: 'Wear a tie')]
      application_choice = create(:application_choice,
                                  :offered,
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
      expect(application_choice.offer.reload.all_conditions_text).to contain_exactly(
        'Disclosure and Barring Service (DBS) check',
        'Wear a tie',
      )
    end

    it 'can add a SKE condition' do
      conditions = [
        build(:text_condition, description: 'Fitness to train to teach check'),
      ]
      application_choice = create(
        :application_choice,
        :offered,
        offer: build(:offer, conditions:),
      )

      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Fitness to train to teach check',
        ],
        'ske_conditions' => {
          '0' => {
            'ske_required' => 'true',
            'length' => '8',
            'reason' => 'different_degree',
            'subject' => 'Chemistry',
            'subject_type' => 'standard',
          },
        },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      form.save

      expect(application_choice.reload.offer.ske_conditions.count).to eq(1)
      expect(application_choice.offer.ske_conditions.first.subject).to eq('Chemistry')
      expect(application_choice.offer.ske_conditions.first.subject_type).to eq('standard')
      expect(application_choice.offer.ske_conditions.first.reason).to eq('different_degree')
      expect(application_choice.offer.ske_conditions.first.length).to eq('8')
    end

    it 'can update a SKE condition' do
      conditions = [
        build(:text_condition, description: 'Fitness to train to teach check'),
        build(
          :ske_condition,
          length: '12',
          reason: 'outdated_degree',
          subject: 'Chemistry',
          subject_type: 'standard',
        ),
      ]
      application_choice = create(
        :application_choice,
        :offered,
        offer: build(:offer, conditions:),
      )

      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Fitness to train to teach check',
        ],
        'ske_conditions' => {
          '0' => {
            'ske_required' => 'true',
            'length' => '8',
            'reason' => 'different_degree',
            'subject' => 'Chemistry',
            'subject_type' => 'standard',
          },
        },
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      form.save

      expect(application_choice.reload.offer.ske_conditions.count).to eq(1)
      expect(application_choice.offer.ske_conditions.first.subject).to eq('Chemistry')
      expect(application_choice.offer.ske_conditions.first.subject_type).to eq('standard')
      expect(application_choice.offer.ske_conditions.first.reason).to eq('different_degree')
      expect(application_choice.offer.ske_conditions.first.length).to eq('8')
    end

    it 'can remove a SKE condition' do
      conditions = [
        build(:text_condition, description: 'Fitness to train to teach check'),
        build(:ske_condition),
      ]
      application_choice = create(
        :application_choice,
        :offered,
        offer: build(:offer, conditions:),
      )

      form = described_class.build_from_params(
        application_choice,
        'standard_conditions' => [
          'Fitness to train to teach check',
        ],
        'ske_conditions' => {},
        'audit_comment_ticket' => 'https://becomingateacher.zendesk.com/agent/tickets/12345',
      )
      form.save

      expect(application_choice.reload.offer.ske_conditions.count).to eq(0)
    end

    it 'includes an audit comment', :with_audited do
      application_choice = create(:application_choice, :offered)
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
      conditions = [build(:text_condition, description: OfferCondition::STANDARD_CONDITIONS.sample),
                    build(:text_condition, description: 'Get a haircut')]
      application_choice = create(:application_choice,
                                  :offered,
                                  offer: build(:offer, conditions:))
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([conditions.first.text])
      expect(form.further_condition_attrs).to eq({
        '0' => { 'text' => conditions.last.text, 'condition_id' => conditions.last.id },
        '1' => { 'text' => '' },
      })
    end

    it 'reads SKE conditions' do
      conditions = [
        build(:text_condition, description: OfferCondition::STANDARD_CONDITIONS.sample),
        build(:text_condition, description: 'Get a haircut'),
        build(:ske_condition),
      ]
      application_choice = create(
        :application_choice,
        :offered,
        offer: build(:offer, conditions:),
      )

      form = described_class.build_from_application_choice(application_choice)

      expect(form.ske_conditions.count).to eq(1)
    end

    it 'reads more than 4 further conditions' do
      conditions = [build(:text_condition, description: 'Fitness to train to teach check'),
                    build(:text_condition, description: 'FC1'),
                    build(:text_condition, description: 'FC2'),
                    build(:text_condition, description: 'FC3'),
                    build(:text_condition, description: 'FC4'),
                    build(:text_condition, description: 'FC5')]
      application_choice = create(:application_choice,
                                  :offered,
                                  offer: build(:offer, conditions:))
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq(['Fitness to train to teach check'])
      expect(form.further_condition_attrs.values.map { |hash| hash['text'] }).to eq(['FC1', 'FC2', 'FC3', 'FC4', 'FC5', ''])
    end
  end

  describe '#ske_length_options' do
    before do
      @application_choice = create(:application_choice, :offered, offer: build(:offer))
      @form = described_class.build_from_application_choice(@application_choice)
    end

    it 'returns a CheckBoxOption for each possible length' do
      expect(@form.ske_length_options.size).to eq(6)
    end
  end
end

require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe DataMigrations::BackfillOfferData do
  it 'does nothing when the application choice does not have an offer' do
    create(:application_choice)

    expect { described_class.new.change }.not_to change(Offer, :count)
  end

  it 'backfills information of offers without conditions' do
    create_list(:application_choice, 3, offer: { conditions: [] }, offered_at: Time.zone.now)

    expect { described_class.new.change }.to change(Offer, :count).by(3)
    expect(OfferCondition.count).to be(0)
  end

  it 'backfills information of offers with conditions' do
    application_choice = create(:application_choice, :with_offer)
    other_application_choice = create(:application_choice, :with_offer, offer: { conditions: %w[One Two] })

    expect { described_class.new.change }.to change(Offer, :count).by(2)

    expect(Offer.find_by(application_choice: application_choice).conditions.map(&:text)).to eq(application_choice.offer['conditions'])
    expect(Offer.find_by(application_choice: other_application_choice).conditions.map(&:text)).to eq(%w[One Two])
    expect(OfferCondition.count).to be(3)
  end

  it 'backfills the correct condition status based on the offer state' do
    application_choice_with_offer = create(:application_choice, :with_offer)
    application_choice_recruited = create(:application_choice, :with_offer, :recruited)
    application_choice_conditions_not_met = create(:application_choice, :with_offer, :conditions_not_met)

    expect { described_class.new.change }.to change(Offer, :count).by(3)

    expect(Offer.find_by(application_choice: application_choice_with_offer).conditions.first.status).to eq('pending')
    expect(Offer.find_by(application_choice: application_choice_recruited).conditions.first.status).to eq('met')
    expect(Offer.find_by(application_choice: application_choice_conditions_not_met).conditions.first.status).to eq('unmet')
  end

  it 'does not update the audit log' do
    create(:application_choice, :with_offer)

    expect { described_class.new.change }
      .to change(Offer, :count).by(1)
      .and not_change(Audited::Audit, :count)
  end
end

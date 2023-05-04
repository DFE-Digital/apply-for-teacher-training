require 'rails_helper'

RSpec.describe DataMigrations::MigrateToStructuredOfferConditions do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  before do
    @reference_condition = create(:reference_condition, updated_at: 1.day.ago)
    @ske_condition = create(:ske_condition, updated_at: 1.day.ago)
    @text_condition = create(:text_condition, updated_at: 1.day.ago)
    @offer_condition = create(:offer_condition, updated_at: 1.day.ago)
  end

  it 'does not alter existing structured condition records' do
    described_class.new.change

    [@reference_condition, @ske_condition, @text_condition].each do |structured_condition|
      expect(structured_condition.reload.updated_at).to eq(1.day.ago)
    end
  end

  it 'updates unstructured condition records to `TextCondition` records' do
    described_class.new.change

    converted_text_condition = TextCondition.find(@offer_condition.id)
    expect(converted_text_condition.updated_at).to eq(Time.zone.now)
    expect(converted_text_condition.description).to eq(@offer_condition.text)
    expect(converted_text_condition.text).to eq(@offer_condition.text)
  end
end

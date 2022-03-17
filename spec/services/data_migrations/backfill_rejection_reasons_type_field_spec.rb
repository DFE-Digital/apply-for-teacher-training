require 'rails_helper'

RSpec.describe DataMigrations::BackfillRejectionReasonsTypeField do
  it 'assigns a type for choices with structured and text reasons' do
    structured_choices = create_list(:application_choice, 2, :with_structured_rejection_reasons)
    rejected_choices = create_list(:application_choice, 2, rejection_reason: 'abc')

    described_class.new.change

    expect(structured_choices.map(&:reload).map(&:rejection_reasons_type).uniq).to eq(%w[reasons_for_rejection])
    expect(rejected_choices.map(&:reload).map(&:rejection_reasons_type).uniq).to eq(%w[rejection_reason])
  end
end

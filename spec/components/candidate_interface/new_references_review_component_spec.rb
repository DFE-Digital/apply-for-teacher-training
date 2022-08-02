require 'rails_helper'

RSpec.describe CandidateInterface::NewReferencesReviewComponent, type: :component do
  it 'renders the referee name and email' do
    reference = create(:reference, :not_requested_yet)
    result = render_inline(described_class.new(references: [reference]))

    name_row = result.css('.govuk-summary-list__row')[1].text
    email_row = result.css('.govuk-summary-list__row')[2].text
    expect(name_row).to include 'Name'
    expect(name_row).to include reference.name
    expect(email_row).to include 'Email'
    expect(email_row).to include reference.email_address
  end

  it 'renders the reference type' do
    reference = create(:reference, :not_requested_yet, referee_type: :school_based)
    result = render_inline(described_class.new(references: [reference]))

    type_row = result.css('.govuk-summary-list__row')[0].text
    expect(type_row).to include 'Type'
    expect(type_row).to include 'School-based'
  end

  it 'renders the relationship' do
    reference = create(:reference, :not_requested_yet)
    result = render_inline(described_class.new(references: [reference]))

    relationship_row = result.css('.govuk-summary-list__row')[3].text
    expect(relationship_row).to include 'Relationship to you'
    expect(relationship_row).to include reference.relationship
  end

  it 'renders all references passed in' do
    reference_one = create(:reference)
    reference_two = create(:reference)

    result = render_inline(described_class.new(references: [reference_one, reference_two]))
    expect(result.text).to include reference_one.email_address
    expect(result.text).to include reference_two.email_address
  end

  context 'when a reference is carried over' do
    context 'when the state is feedback_provided' do
      it 'renders a status row' do
        reference = create(:reference, :feedback_provided)
        result = render_inline(described_class.new(references: [reference]))

        status_row = result.css('.govuk-summary-list__row')[4].text
        expect(status_row).to include 'Status'
        expect(status_row).to include 'Reference received'
        expect(status_row).to include "#{reference.name} will not be asked to give you another reference."
      end
    end

    context 'when the state is not feedback_provided' do
      it 'does not render a status row' do
        reference = create(:reference, :feedback_requested)
        result = render_inline(described_class.new(references: [reference]))

        status_row = result.css('.govuk-summary-list__row')[4]
        expect(status_row).to be_nil
      end
    end
  end
end

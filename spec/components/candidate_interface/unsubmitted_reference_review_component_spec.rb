require 'rails_helper'

RSpec.describe CandidateInterface::UnsubmittedReferenceReviewComponent do
  let(:reference) { create(:reference) }

  it 'renders component with correct values for a references name' do
    result = render_inline(described_class.new(reference: reference))

    expect(result.css('.govuk-summary-list__key')[0].text).to include('Name')
    expect(result.css('.govuk-summary-list__value')[0].to_html).to include(reference.name)
    expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
      Rails.application.routes.url_helpers.candidate_interface_references_edit_name_path(reference.id),
    )
    expect(result.css('.govuk-summary-list__actions')[0].text).to include("Change name for #{reference.name}")
  end

  it 'renders component with correct values for the references email address' do
    result = render_inline(described_class.new(reference: reference))

    expect(result.css('.govuk-summary-list__key')[1].text).to include('Email address')
    expect(result.css('.govuk-summary-list__value')[1].to_html).to include(reference.email_address)
    expect(result.css('.govuk-summary-list__actions a')[1].attr('href')).to include(
      Rails.application.routes.url_helpers.candidate_interface_references_edit_email_address_path(reference.id),
    )
    expect(result.css('.govuk-summary-list__actions')[1].text).to include("Change email address for #{reference.name}")
  end

  it 'renders component with correct values for the references type' do
    result = render_inline(described_class.new(reference: reference))

    expect(result.css('.govuk-summary-list__key')[2].text).to include('Reference type')
    expect(result.css('.govuk-summary-list__value')[2].to_html).to include(reference.referee_type.capitalize.dasherize)
    expect(result.css('.govuk-summary-list__actions a')[2].attr('href')).to include(
      Rails.application.routes.url_helpers.candidate_interface_references_edit_type_path(reference.referee_type, reference.id),
    )
    expect(result.css('.govuk-summary-list__actions')[2].text).to include("Change reference type for #{reference.name}")
  end

  it 'renders component with correct values for the references relationship' do
    result = render_inline(described_class.new(reference: reference))

    expect(result.css('.govuk-summary-list__key')[3].text).to include('Relationship to referee')
    expect(result.css('.govuk-summary-list__value')[3].to_html).to include(reference.relationship)
    expect(result.css('.govuk-summary-list__actions a')[3].attr('href')).to include(
      Rails.application.routes.url_helpers.candidate_interface_references_edit_relationship_path(reference.id),
    )
    expect(result.css('.govuk-summary-list__actions')[3].text).to include("Change relationship for #{reference.name}")
  end
end

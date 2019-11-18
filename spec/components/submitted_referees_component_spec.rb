require 'rails_helper'

RSpec.describe SubmittedRefereesComponent do
  let(:application_form) do
    create(:completed_application_form, references_count: 2)
  end

  it "renders component with correct values for a referee's name" do
    first_referee = application_form.references.first
    result = render_inline(SubmittedRefereesComponent, application_form: application_form)

    expect(result.css('.app-summary-card__title').text).to include('First referee')
    expect(result.css('.govuk-summary-list__key').text).to include('Name')
    expect(result.css('.govuk-summary-list__value').to_html).to include(first_referee.name)
  end

  it "renders component with correct values for a referee's email address" do
    first_referee = application_form.references.first
    result = render_inline(SubmittedRefereesComponent, application_form: application_form)

    expect(result.css('.govuk-summary-list__key').text).to include('Email address')
    expect(result.css('.govuk-summary-list__value').to_html).to include(first_referee.email_address)
  end
end

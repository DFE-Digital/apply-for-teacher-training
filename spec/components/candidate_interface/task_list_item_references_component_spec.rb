require 'rails_helper'

RSpec.describe CandidateInterface::TaskListItemReferencesComponent do
  it 'renders a `Review you references` link when two references have been provided' do
    application_form = create(:application_form)
    create_list(:reference, 2, :feedback_provided, application_form: application_form)

    render_inline(described_class.new(references: application_form.application_references))

    expect(page).to have_link('Review your references', href: Rails.application.routes.url_helpers.candidate_interface_references_review_path)
  end

  it 'renders a `Request your references` link which goes to the review page when one than two references have been provided' do
    application_form = create(:application_form)
    create(:reference, :feedback_provided, application_form: application_form)

    render_inline(described_class.new(references: application_form.application_references))

    expect(page).to have_link('Request your references', href: Rails.application.routes.url_helpers.candidate_interface_references_review_path)
  end

  it 'renders a `Request your references` link which goes to the start page when noreferences have been provided' do
    application_form = create(:application_form)

    render_inline(described_class.new(references: application_form.application_references))

    expect(page).to have_link('Request your references', href: Rails.application.routes.url_helpers.candidate_interface_references_start_path)
  end
end

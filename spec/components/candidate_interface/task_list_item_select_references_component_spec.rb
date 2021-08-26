require 'rails_helper'

RSpec.describe CandidateInterface::TaskListItemSelectReferencesComponent do
  it 'renders a `Select 2 references` link to the select references page when two references have been provided' do
    application_form = create(:application_form)
    create_list(:reference, 2, :feedback_provided, application_form: application_form)
    application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

    render_inline(described_class.new(application_form_presenter: application_form_presenter))

    expect(page).to have_link 'Select 2 references', href: Rails.application.routes.url_helpers.candidate_interface_select_references_path
  end

  it 'does not render a link to the select references page when insufficient references have been provided' do
    application_form = create(:application_form)
    create(:reference, :feedback_provided, application_form: application_form)
    application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

    result = render_inline(described_class.new(application_form_presenter: application_form_presenter))

    expect(result.text).to include 'Select 2 references'
    expect(result.css('a')).to be_empty
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::ReferencesGuidanceComponent do
  it 'does not render when the references section has been completed' do
    application_form = create(:application_form, references_completed: true)
    create_list(:reference, 2, :feedback_provided, application_form: application_form)

    result = render_inline(described_class.new(references: application_form.application_references))

    expect(result.text).to be_blank
  end

  it 'renders the correct content when more than 2 references have been provided' do
    application_form = create(:application_form)
    create_list(:reference, 3, :feedback_provided, application_form: application_form)

    result = render_inline(described_class.new(references: application_form.application_references))

    expect(result.text).to include 'You have more than enough references to send your application to training providers.'
  end

  it 'renders the correct content when two references have been provided' do
    application_form = create(:application_form)
    create_list(:reference, 2, :feedback_provided, application_form: application_form)

    result = render_inline(described_class.new(references: application_form.application_references))

    expect(result.text).to include 'You have enough references to send your application to training providers.'
  end

  it 'renders the correct content when less than 2 references have been provided' do
    application_form = create(:application_form)
    create(:reference, :feedback_provided, application_form: application_form)

    result = render_inline(described_class.new(references: application_form.application_references))

    expect(result.text).to include 'Your application needs to include 2 references.'
  end
end

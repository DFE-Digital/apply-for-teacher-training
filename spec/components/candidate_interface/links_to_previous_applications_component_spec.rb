require 'rails_helper'

RSpec.describe CandidateInterface::LinksToPreviousApplicationsComponent do
  let(:candidate) { build(:candidate) }
  let(:application_form) { create(:application_form, candidate: candidate, phase: :apply_2) }
  let(:previous_application_form) { create(:completed_application_form, candidate: candidate, phase: :apply_2, submitted_at: 3.days.ago) }
  let(:first_application_form) { create(:completed_application_form, candidate: candidate, phase: :apply_1, submitted_at: 5.days.ago) }

  before do
    application_form
    previous_application_form
    first_application_form
  end

  it 'renders component with links to the candidates previous applications in chronological order' do
    result = render_inline(described_class.new(application_form: application_form))

    expect(result.css('.govuk-link')[0].text).to eq('First application')
    expect(result.css('.govuk-body-s')[0].text).to include("Submitted #{first_application_form.submitted_at.to_s(:govuk_date).strip}")
    expect(result.css('.govuk-link')[1].text).to eq('Second application')
    expect(result.css('.govuk-body-s')[1].text).to include("Submitted #{previous_application_form.submitted_at.to_s(:govuk_date).strip}")
  end
end

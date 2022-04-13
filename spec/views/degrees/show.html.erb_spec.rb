require 'rails_helper'

RSpec.describe 'candidate_interface/degrees/degree/review/show' do
  before do
    assign(:application_form, application_form)
    assign(:section_complete_form, CandidateInterface::SectionCompleteForm.new(completed: 'No'))
    render
  end

  context 'with no degrees' do
    let(:application_form) { create(:application_form) }

    it 'renders the degree empty component' do
      expect(rendered).to have_text('Add your bachelor’s degree even if you have not got your grade yet.')
      expect(rendered).to have_text('Add a degree')
      expect(rendered).to match('<a primary="true" class="govuk-button"')
    end

    it 'does not render the complete section component' do
      expect(rendered).not_to have_text('Have you completed this section?')
    end
  end

  context 'with only foundation degrees' do
    let(:application_form) do
      degree = create(:application_form, :with_degree)
      degree.application_qualifications.first.update!(qualification_type: 'Foundation of Arts')
      degree
    end

    it 'renders the degree empty component' do
      expect(rendered).to have_text('Add your bachelor’s degree even if you have not got your grade yet.')
      expect(rendered).to have_text('Add another degree')
      expect(rendered).not_to match('<a class="govuk-button govuk-button--secondary"')
    end

    it 'does not render the complete section component' do
      expect(rendered).not_to have_text('Have you completed this section?')
    end
  end

  context 'with a bachelor degree' do
    let(:application_form) do
      degree = create(:application_form, :with_degree)
      degree.application_qualifications.first.update!(qualification_type: 'Bachelor of Arts')
      degree
    end

    it 'does not render the degree empty component' do
      expect(rendered).not_to have_text('Add your bachelor’s degree even if you have not got your grade yet.')
      expect(rendered).to have_text('Add another degree')
      expect(rendered).to match('<a class="govuk-button govuk-button--secondary"')
    end

    it 'renders the complete section component' do
      expect(rendered).to have_text('Have you completed this section?')
    end
  end
end

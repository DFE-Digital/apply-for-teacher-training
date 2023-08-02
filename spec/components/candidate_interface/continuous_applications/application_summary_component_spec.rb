require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationSummaryComponent, type: :component do
  subject(:result) do
    render_inline(described_class.new(application_choice:))
  end

  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision)
  end
  let(:actions) { result.css('.govuk-summary-card__actions').text }

  it 'renders a View application link' do
    expect(actions).to include('View application')
  end

  it 'renders the course information' do
    expect(result.text).to include(application_choice.current_course.name_and_code)
  end

  context 'when application is unsubmitted' do
    let(:application_choice) do
      create(:application_choice, :unsubmitted)
    end

    it 'renders component with delete link' do
      expect(actions).to include(t('application_form.continuous_applications.courses.delete'))
    end

    it 'renders the status' do
      expect(result.text).to include('StatusNot sent')
    end
  end

  context 'when application is not unsubmitted' do
    let(:application_choice) do
      create(:application_choice, :offered)
    end

    it 'renders component without delete link' do
      expect(actions).not_to include(t('application_form.continuous_applications.courses.delete'))
    end

    it 'renders the status' do
      expect(result.text).to include('StatusOffer received')
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationSummaryComponent, :continuous_applications, type: :component do
  subject(:result) do
    render_inline(described_class.new(application_choice:))
  end

  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision)
  end
  let(:actions) { result.css('.govuk-summary-card__actions').text }
  let(:links) { result.css('a').map(&:text).join(' ') }

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

    it 'renders the continue application link' do
      expect(links).to include('Continue application')
    end

    context 'when application course is not full' do
      it 'renders the `View application` link without the course full info and `Change` link' do
        expect(result.text).not_to include('You cannot apply to this course as there are no places left on it')
        expect(result.text).not_to include('You need to either delete or change this course choice')
        expect(result.text).not_to include('may be able to recommend an alternative course')
        expect(actions).to include('View application')
        expect(links).not_to include('Change')
      end
    end

    context 'when application course is full' do
      let(:course) { create(:course, :with_no_vacancies) }
      let(:application_choice) { create(:application_choice, :unsubmitted, course:) }

      it 'renders the course full info and `Change` link without the `View application` link' do
        expect(result.text).to include('You cannot apply to this course as there are no places left on it')
        expect(result.text).to include('You need to either delete or change this course choice')
        expect(result.text).to include("#{application_choice.course.provider.name} may be able to recommend an alternative course.")
        expect(actions).not_to include('View application')
        expect(links).to include('Change')
      end
    end
  end

  context 'when application is offered' do
    let(:application_choice) do
      create(:application_choice, :offered)
    end

    it 'renders component without delete link' do
      expect(actions).not_to include(t('application_form.continuous_applications.courses.delete'))
    end

    it 'renders the status' do
      expect(result.text).to include('StatusOffer received')
    end

    it 'does not show the decline by default message' do
      expect(result.text).not_to include('You do not need to respond to this offer yet')
    end
  end
end

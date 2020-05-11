require 'rails_helper'

RSpec.describe CandidateInterface::RefereeGuidanceComponent do
  include CourseOptionHelpers

  let(:provider) { create(:provider) }

  def setup_application
    course_option_for_provider(provider: provider)
    @application_form = create(:application_form)
    create(:application_choice, application_form: @application_form, course_option: provider.courses.first.course_options.first)
    create(:reference, :requested, application_form: @application_form)
  end

  before do
    setup_application
  end

  context 'when one reference is in the feedback_requested state' do
    context 'when the candidates courses all have the same provider' do
      it 'renders the correct pluralization for referees, references and providerss' do
        result = render_inline(described_class.new(application_form: @application_form))

        expect(result.css('.govuk-heading-m').text).to eq('Reference')
        expect(result.css('.govuk-body').text).to include('training provider')
        expect(result.css('.govuk-body').text).not_to include('training providers')
      end
    end

    context 'when the candidates courses have different providers' do
      it 'renders the correct pluralization for referees, references and providers' do
        provider2 = create(:provider)
        course_option_for_provider(provider: provider2)
        create(:application_choice, application_form: @application_form, course_option: provider2.courses.first.course_options.first)
        result = render_inline(described_class.new(application_form: @application_form))

        expect(result.css('.govuk-heading-m').text).to eq('Reference')
        expect(result.css('.govuk-body').text).to include('training providers')
      end
    end
  end

  context 'when two references are in the feedback_requested state' do
    context 'when the candidates courses all have the same provider' do
      it 'renders the correct pluralization for referees, references and providers' do
        create(:reference, :requested, application_form: @application_form)
        result = render_inline(described_class.new(application_form: @application_form))

        expect(result.css('.govuk-heading-m').text).to eq('References')
        expect(result.css('.govuk-body').text).to include('training provider')
        expect(result.css('.govuk-body').text).not_to include('training providers')
      end
    end

    context 'when the candidates courses have different providers' do
      it 'renders the correct pluralization for referees, references and providers' do
        provider2 = create(:provider)
        course_option_for_provider(provider: provider2)
        create(:application_choice, application_form: @application_form, course_option: provider2.courses.first.course_options.first)
        create(:reference, :requested, application_form: @application_form)
        result = render_inline(described_class.new(application_form: @application_form))

        expect(result.css('.govuk-heading-m').text).to eq('References')
        expect(result.css('.govuk-body').text).to include('training providers')
      end
    end
  end
end

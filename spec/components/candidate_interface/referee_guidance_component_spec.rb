require 'rails_helper'

RSpec.describe CandidateInterface::RefereeGuidanceComponent do
  include CourseOptionHelpers

  let(:provider) { create(:provider) }

  context 'when one reference is in the feedback_requested state' do
    context 'when the candidates courses all have the same provider' do
      it 'renders the correct singular content for referees, references and providers' do
        course_option_for_provider(provider: provider)
        application_form = create(:application_form)
        create(:application_choice, application_form: application_form, course_option: provider.courses.first.course_options.first)
        create(:reference, :requested, application_form: application_form)
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-heading-m').text).to eq('Reference')
        expect(result.css('.govuk-body').text).to include('training provider')
        expect(result.css('.govuk-body').text).not_to include('training providers')
      end
    end

    context 'when the candidates courses have different providers' do
      it 'renders the correct singular content for referees, references and providers' do
        provider2 = create(:provider)
        course_option_for_provider(provider: provider)
        course_option_for_provider(provider: provider2)
        application_form = create(:application_form)
        create(:application_choice, application_form: application_form, course_option: provider.courses.first.course_options.first)
        create(:application_choice, application_form: application_form, course_option: provider2.courses.first.course_options.first)
        create(:reference, :requested, application_form: application_form)
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-heading-m').text).to eq('Reference')
        expect(result.css('.govuk-body').text).to include('training providers')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::CourseChangeWarningTextComponent do
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
  let(:course_option) { create(:course_option, course: create(:course)) }

  let(:course_wizard) do
    instance_double(
      ProviderInterface::CourseWizard,
      application_choice_id: application_choice.id,
      course_id: course_option.course.id,
      course_option_id: course_option.id,
      provider_id: course_option.provider.id,
      study_mode: course_option.study_mode,
      location_id: course_option.site.id,
    )
  end

  let(:render) do
    render_inline(described_class.new(
                    application_choice: application_choice,
                    wizard: course_wizard,
                  ))
  end

  before do
    allow(course_wizard).to receive(:course_option).and_return(course_option)
  end

  context 'when there is an interview' do
    let(:application_choice) { create(:application_choice, :with_scheduled_interview) }

    it 'renders the warning text' do
      expect(render.css('.govuk-warning-text').text).to include '!WarningThe upcoming interview will be updated with the new course details.'
      expect(render.css('.govuk-warning-text').text).to include 'The candidate will be sent emails to tell them that the course and the upcoming interview have been updated.'
    end
  end

  context 'when there are multiple interviews' do
    let(:application_choice) { create(:application_choice, status: :interviewing, interviews: create_list(:interview, 2)) }

    it 'renders the warning text' do
      expect(render.css('.govuk-warning-text').text).to include '!WarningThe upcoming interviews will be updated with the new course details.'
      expect(render.css('.govuk-warning-text').text).to include 'The candidate will be sent emails to tell them that the course and the upcoming interviews have been updated.'
    end
  end

  context 'when only the study mode is changed' do
    let(:course_wizard) do
      instance_double(
        ProviderInterface::CourseWizard,
        application_choice_id: application_choice.id,
        course_id: application_choice.course_option.course.id,
        course_option_id: application_choice.course_option.id,
        provider_id: application_choice.course_option.provider.id,
        study_mode: course_option.study_mode,
        location_id: application_choice.course_option.site.id,
      )
    end

    it 'renders the warning text' do
      expect(render.css('.govuk-warning-text').text).not_to include '!WarningThe upcoming interview will be updated with the new course details.'
      expect(render.css('.govuk-warning-text').text).to include '!WarningThe candidate will be sent an email to tell them that the course has been updated.'
    end
  end

  context 'when only the location is changed' do
    let(:course_wizard) do
      instance_double(
        ProviderInterface::CourseWizard,
        application_choice_id: application_choice.id,
        course_id: application_choice.course_option.course.id,
        course_option_id: application_choice.course_option.id,
        provider_id: application_choice.course_option.provider.id,
        study_mode: application_choice.course_option.study_mode,
        location_id: course_option.site.id,
      )
    end

    it 'renders the warning text' do
      expect(render.css('.govuk-warning-text').text).not_to include '!WarningThe upcoming interview will be updated with the new course details.'
      expect(render.css('.govuk-warning-text').text).to include '!WarningThe candidate will be sent an email to tell them that the course has been updated.'
    end
  end

  it 'renders the warning text' do
    expect(render.css('.govuk-warning-text').text).to eq '!WarningThe candidate will be sent an email to tell them that the course has been updated.'
  end
end

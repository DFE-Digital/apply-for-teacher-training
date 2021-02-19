require 'rails_helper'

RSpec.describe ProviderInterface::InterviewAndCourseSummaryComponent do
  let(:interview) { create(:interview) }
  let(:component) { render_inline(described_class.new(interview: interview, user_can_change_interview: true)).text }

  it 'capitalises funding type' do
    expect(component).to include(interview.application_choice.course.funding_type.capitalize)
  end

  it 'displays interview preferences' do
    expect(component).to include(interview.application_choice.application_form.interview_preferences)
  end

  it 'displays the provider name' do
    expect(component).to include(interview.application_choice.course.provider.name)
  end

  it 'displays the course name and code' do
    expect(component).to include(interview.application_choice.course.name_and_code)
  end

  it 'displays interview location' do
    expect(component).to include(interview.location)
  end

  it 'change link has a hidden field to improve accessibility for visually impaired users' do
    component = render_inline(described_class.new(interview: interview, user_can_change_interview: true))
    expect(component.css('.govuk-visually-hidden').first.text).to include(interview.date_and_time.to_s(:govuk_date_and_time))
  end

  it 'cancel link has a hidden field to improve accessibility for visually impaired users' do
    component = render_inline(described_class.new(interview: interview, user_can_change_interview: true))
    expect(component.css('.govuk-visually-hidden').last.text).to include(interview.date_and_time.to_s(:govuk_date_and_time))
  end

  context 'additional details' do
    it 'displays the additional details' do
      interview.additional_details = 'Test'
      expect(component).to include('Test')
    end

    it 'displays additional details as None when no additional details provided' do
      interview.additional_details = ''
      expect(component).to include('None')
    end
  end

  context 'user_can_change_interview is false' do
    let(:component) { render_inline(described_class.new(interview: interview, user_can_change_interview: false)).text }

    it 'does not render the edit or cancel buttons' do
      expect(component).not_to include('Change details')
      expect(component).not_to include('Cancel interview')
    end
  end
end

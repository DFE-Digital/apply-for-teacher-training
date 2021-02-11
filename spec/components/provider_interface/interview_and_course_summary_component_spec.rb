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

  it 'displays the course name' do
    expect(component).to include(interview.application_choice.course.name)
  end

  it 'displays interview location' do
    expect(component).to include(interview.location)
  end

  context 'user_can_change_interview is false' do
    let(:component) { render_inline(described_class.new(interview: interview, user_can_change_interview: false)).text }

    it 'does not render the edit or cancel buttons' do
      expect(component).not_to include('Change details')
      expect(component).not_to include('Cancel interview')
    end
  end

end

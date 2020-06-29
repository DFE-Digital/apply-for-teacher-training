require 'rails_helper'

RSpec.describe InterviewPreferencesComponent do
  it 'renders `No preferences` if `#interview_preferences` is nil' do
    application_form = instance_double(
      ApplicationForm,
      interview_preferences: nil,
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('No preferences.')
  end

  it 'renders `No preferences` if `#interview_preferences` is blank' do
    application_form = instance_double(
      ApplicationForm,
      interview_preferences: '',
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('No preferences.')
  end

  it 'renders interview preferences if there are any' do
    application_form = instance_double(
      ApplicationForm,
      interview_preferences: 'Fridays are best for me.',
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Fridays are best for me.')
  end
end

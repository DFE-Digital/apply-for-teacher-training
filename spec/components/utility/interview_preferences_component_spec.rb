require 'rails_helper'

RSpec.describe InterviewPreferencesComponent do
  context 'when there are no interview needs' do
    it 'rendes no interview needs message' do
      application_form = instance_double(
        ApplicationForm,
        interview_preferences: nil,
      )
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Do you have any interview needs?No')
      expect(result.text).not_to include('What are your interview needs?')
    end
  end

  context 'when interview needs are left blank' do
    it 'rendes no interview needs message' do
      application_form = instance_double(
        ApplicationForm,
        interview_preferences: '',
      )
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Do you have any interview needs?No')
      expect(result.text).not_to include('What are your interview needs?')
    end
  end

  context 'when there are interview needs' do
    it 'renders interview preferences' do
      application_form = instance_double(
        ApplicationForm,
        interview_preferences: 'Fridays are best for me.',
      )
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Do you have any interview needs?Yes')
      expect(result.text).to include('What are your interview needs?Fridays are best for me.')
    end
  end
end

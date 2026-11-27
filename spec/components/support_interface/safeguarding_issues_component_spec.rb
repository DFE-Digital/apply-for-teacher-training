require 'rails_helper'

RSpec.describe SupportInterface::SafeguardingIssuesComponent do
  let(:candidate) { build_stubbed(:candidate) }

  context 'when the candidate was never asked the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'never_asked',
        candidate:,
      )
      result = render_inline(described_class.new(application_form:, current_user: candidate))

      expect(result.text).to include('Never asked.')
    end
  end

  context 'when the candidate has shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        candidate:,
      )
      result = render_inline(described_class.new(application_form:, current_user: candidate))

      expect(result.text).to include('The candidate has shared information related to safeguarding.')
    end
  end

  context 'when the candidate has no safeguarding issues to declare' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'no_safeguarding_issues_to_declare',
        candidate:,
      )
      result = render_inline(described_class.new(application_form:, current_user: candidate))

      expect(result.text).to include('The candidate has declared no criminal convictions or other safeguarding issues.')
    end
  end

  context 'when the candidate has not answered the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'not_answered_yet',
        candidate:,
      )
      result = render_inline(described_class.new(application_form:, current_user: candidate))

      expect(result.text).to include('Not answered yet')
    end
  end

  context 'when the candidate has declared a previous teacher training' do
    let(:candidate) { create(:candidate) }
    
    it 'displays a button to add another course' do
      application_form = create(
        :application_form,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        candidate:,
        previous_teacher_trainings: [build(:previous_teacher_training, :published)],
      )
      result = render_inline(described_class.new(application_form:, current_user: candidate))

      expect(result.text).to include('Add another course')
    end
  end
end

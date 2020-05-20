require 'rails_helper'

RSpec.describe ProviderInterface::SafeguardingDeclarationComponent do
  context 'when the candidate was never asked the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'never_asked',
      )
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Never asked.')
    end
  end

  context 'when the candidate has shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('The candidate has shared information related to safeguarding. Please contact them directly for more details.')
    end
  end

  context 'when the candidate has not shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'no_safeguarding_issues_to_declare',
      )
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('No information shared.')
    end
  end

  context 'when the candidate has not answered the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'not_answered_yet',
      )
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Not answered yet')
    end
  end
end

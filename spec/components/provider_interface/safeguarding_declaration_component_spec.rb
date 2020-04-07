require 'rails_helper'

RSpec.describe ProviderInterface::SafeguardingDeclarationComponent do
  let(:heading) { 'Criminal convictions and professional misconduct' }
  let(:has_shared_text) { 'The candidate has shared information related to safeguarding. Please contact them directly for more details.' }
  let(:has_not_shared_text) { 'No information shared' }
  let(:has_not_answered_text) { 'Not answered' }


  context 'when the candidate has entered "Yes" as an answer to the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(:application_form, safeguarding_issues: 'Yes')

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(heading)
      expect(result.text).to include(has_shared_text)
    end
  end

  context 'when the candidate has shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(:application_form, safeguarding_issues: 'I have a criminal conviction.')
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(heading)
      expect(result.text).to include(has_shared_text)
    end
  end

  context 'when the candidate has not shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(:application_form, safeguarding_issues: 'No')

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(heading)
      expect(result.text).to include(has_not_shared_text)
    end
  end

  context 'when the candidate has not answered the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(:application_form, safeguarding_issues: nil)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(heading)
      expect(result.text).to include(has_not_answered_text)
    end
  end
end

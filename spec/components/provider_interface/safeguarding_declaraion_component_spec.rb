require 'rails_helper'

RSpec.describe ProviderInterface::SafeguardingDeclarationComponent do
  context 'when safeguarding issues has a value of "Yes"' do
    it 'displays "Yes" for sharing safeguarding issues and "Not entered" for relevant information' do
      application_form = build_stubbed(:application_form, safeguarding_issues: 'Yes')

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Criminal convictions and professional misconduct')
      expect(result.text).to include('The candidate has shared information related to safeguarding. Please contact them directly for more details.')
    end
  end

  context 'when safeguarding issues has a value of "No"' do
    it 'displays "No" for sharing safeguarding issues and "Not entered" for relevant information' do
      application_form = build_stubbed(:application_form, safeguarding_issues: 'No')

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Criminal convictions and professional misconduct')
      expect(result.text).to include('No information shared')
    end
  end
end

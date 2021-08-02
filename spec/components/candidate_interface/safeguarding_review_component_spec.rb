require 'rails_helper'

RSpec.describe CandidateInterface::SafeguardingReviewComponent do
  context 'when safeguarding issues has a value of "Yes"' do
    it 'displays "Yes" for sharing safeguarding issues and "Not entered" for relevant information' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to share any safeguarding issues?')
      expect(result.text).to include('Yes')
      expect(result.text).to include('Relevant information')
      expect(result.text).to include('Not entered')
    end
  end

  context 'when safeguarding issues has a value of "No"' do
    it 'displays "No" for sharing safeguarding issues and "Not entered" for relevant information' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: :no_safeguarding_issues_to_declare,
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to share any safeguarding issues?')
      expect(result.text).to include('No')
      expect(result.text).not_to include('Relevant information')
    end
  end

  context 'when safeguarding issues has details' do
    it 'displays "Yes" for sharing safeguarding issues and the details for relevant information' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to share any safeguarding issues?')
      expect(result.text).to include('Yes')
      expect(result.text).to include('Relevant information')
      expect(result.text).to include('I have a criminal conviction.')
    end
  end

  context 'when editable' do
    it 'renders the component with change links' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      )

      result = render_inline(described_class.new(application_form: application_form, editable: true))

      expect(result.text).to include('Change if you want to share any safeguarding issues')
      expect(result.text).to include('Change relevant information for safeguarding issues')
    end
  end

  context 'when not editable' do
    it 'renders the component without change links' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      )

      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.text).not_to include('Change if you want to share any safeguarding issues')
      expect(result.text).not_to include('Change relevant information for safeguarding issues')
    end
  end
end

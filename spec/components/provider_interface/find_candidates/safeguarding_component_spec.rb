require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::SafeguardingComponent, type: :component do
  context 'when provider user does not have safeguarding persmissions' do
    it 'when the candidate has declared no safeguarding issues' do
      application_form = create(:application_form, :with_accepted_offer)
      provider_user = create(:provider_user, :with_view_safeguarding_information)

      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_css 'h2', text: 'Criminal record and professional misconduct'
      expect(page).to have_css(
        'dt.govuk-summary-list__key',
        text: 'Do you want to declare any safeguarding issues such as a criminal record or professional misconduct?',
      )
      expect(page).to have_css('dd.govuk-summary-list__value', text: 'No')
    end

    it 'when the candidate has declared safeguarding issues' do
      application_form = create(
        :application_form,
        :with_accepted_offer,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      )
      provider_user = create(:provider_user, :with_view_safeguarding_information)

      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_css 'h2', text: 'Criminal record and professional misconduct'
      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'Do you want to declare any safeguarding issues such as a criminal record or professional misconduct?',
      )

      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'Yes, I want to declare something',
      )

      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'Give any relevant information',
      )

      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'You cannot view this because you do not have permission to view criminal record and professional misconduct information.',
      )
    end
  end

  context 'when provider user has safeguarding persmissions' do
    it 'when the candidate has declared no safeguarding issues' do
      application_form = create(:application_form, :with_accepted_offer)
      provider_user = create(:provider_user, :with_view_safeguarding_information)

      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_css 'h2', text: 'Criminal record and professional misconduct'
      expect(page).to have_css(
        'dt.govuk-summary-list__key',
        text: 'Do you want to declare any safeguarding issues such as a criminal record or professional misconduct?',
      )
      expect(page).to have_css('dd.govuk-summary-list__value', text: 'No')
    end

    it 'when the candidate has declared safeguarding issues' do
      application_form = create(
        :application_form,
        :with_accepted_offer,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      )
      provider_user = create(:provider_user)
      create(
        :provider_permissions,
        view_safeguarding_information: true,
        provider_user:,
      )

      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_css 'h2', text: 'Criminal record and professional misconduct'
      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'Do you want to declare any safeguarding issues such as a criminal record or professional misconduct?',
      )

      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'Yes, I want to declare something',
      )

      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'Give any relevant information',
      )

      expect(page).to have_css(
        'dl.govuk-summary-list',
        text: 'I have a criminal conviction.',
      )
    end
  end
end

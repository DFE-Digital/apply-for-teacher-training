require 'rails_helper'

RSpec.describe CandidateInterface::RefereesReviewComponent do
  let(:application_form) do
    create(:completed_application_form, references_count: 2)
  end

  context 'when referees are editable' do
    let(:application_form) { create(:completed_application_form, references_count: 2, with_gces: true) }

    it "renders component with correct values for a referee's name" do
      first_referee = application_form.application_references.first
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('First referee')
      expect(result.css('.govuk-summary-list__key').text).to include('Name')
      expect(result.css('.govuk-summary-list__value').to_html).to include(first_referee.name)
    end

    it "renders component with correct values for a referee's email address" do
      first_referee = application_form.application_references.first
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include('Email address')
      expect(result.css('.govuk-summary-list__value').to_html).to include(first_referee.email_address)
    end

    it 'renders component with correct value for status for unrequested reference' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-tag.app-tag.app-tag--blue').to_html).to include('Not requested yet')
    end

    it 'renders component with correct value for status for given reference' do
      first_referee = application_form.application_references.first
      first_referee.update_column(:feedback_status, 'feedback_provided')
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-tag.app-tag.app-tag--green').to_html).to include('Reference given')
    end

    it 'renders component with correct value for status for given declined' do
      first_referee = application_form.application_references.first
      first_referee.update_column(:feedback_status, 'feedback_refused')
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-tag.app-tag.app-tag--red').to_html).to include('Declined')
    end

    it 'renders component along with a delete link for each referee' do
      referee_id = application_form.application_references.first.id
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.referees.delete'))
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_referee_path(referee_id),
      )
    end

    it 'renders correct text for "Change" links in each attribute row' do
      first_referee = application_form.application_references.first
      result = render_inline(described_class, application_form: application_form)

      change_name = result.css('.govuk-summary-list__actions')[0].text.strip
      change_email = result.css('.govuk-summary-list__actions')[1].text.strip
      change_relationship = result.css('.govuk-summary-list__actions')[2].text.strip

      expect(change_name).to eq("Change name for #{first_referee.name}")
      expect(change_email).to eq("Change email address for #{first_referee.name}")
      expect(change_relationship).to eq("Change relationship for #{first_referee.name}")
    end
  end

  context 'when referees are not editable' do
    let(:application_form) { create(:completed_application_form, references_count: 1, with_gces: true) }

    it 'renders component without an edit link' do
      result = render_inline(described_class, application_form: application_form, editable: false)

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.referees.delete'))
    end
  end

  context 'when the application has not been submitted' do
    it 'renders component with content about what happens with referee details provided' do
      application_form = build_stubbed(:application_form, submitted_at: nil)

      result = render_inline(described_class, application_form: application_form)

      expect(result.text).to include(t('application_form.referees.info.before_submission'))
    end
  end

  context 'when the application has been submitted' do
    it 'renders component with content about referees being contacted' do
      application_form = build_stubbed(:application_form, submitted_at: Time.zone.now)

      result = render_inline(described_class, application_form: application_form)

      expect(result.text).to include(t('application_form.referees.info.after_submission'))
    end
  end
end

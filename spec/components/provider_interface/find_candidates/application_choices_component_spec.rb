require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::ApplicationChoicesComponent, type: :component do
  let(:application_form) { create(:application_form, :submitted) }

  describe 'with draft and submitted applications' do
    it 'only renders submitted applications' do
      create(:application_choice, sent_to_provider_at: 1.day.ago, application_form:)
      create(:application_choice, sent_to_provider_at: nil, application_form:)

      rendered = render_inline(described_class.new(application_form:))

      expect(rendered).to have_text 'Application 1'
      expect(rendered).to have_no_text 'Application 2'
    end
  end

  describe 'many submitted applications' do
    it 'ordered by most recent sent' do
      first_submission_date = 2.days.ago
      create(:application_choice, sent_to_provider_at: first_submission_date, application_form:)

      second_submission_date = 1.day.ago
      create(:application_choice, sent_to_provider_at: second_submission_date, application_form:)

      render_inline(described_class.new(application_form:))
      first_card = page.find('div.govuk-summary-card', text: 'Application 1').text
      second_card = page.find('div.govuk-summary-card', text: 'Application 2').text

      expect(first_card).to have_content second_submission_date.to_fs(:govuk_date)
      expect(second_card).to have_content first_submission_date.to_fs(:govuk_date)
    end
  end

  describe 'heading structures' do
    it 'uses H3 tags for each Application heading' do
      create(:application_choice, sent_to_provider_at: 1.day.ago, application_form:)
      create(:application_choice, sent_to_provider_at: 1.day.ago, application_form:)

      rendered = render_inline(described_class.new(application_form:))

      expect(rendered).to have_css('h3', text: 'Application 1')
      expect(rendered).to have_css('h3', text: 'Application 2')
    end
  end

  describe 'rendered rows' do
    let(:component) { described_class.new(application_form: create(:application_form, :completed, submitted_application_choices_count: 1)) }

    it 'renders the course subject' do
      render_inline(component)

      expect(page).to have_text('Subject')
      expect(page).to have_text('Location')
      expect(page).to have_text('Qualification')
      expect(page).to have_text('Funding type')
      expect(page).to have_text('Full time or part time')
      expect(page).to have_text('Date submitted')
    end
  end
end

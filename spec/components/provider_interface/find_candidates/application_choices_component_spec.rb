require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::ApplicationChoicesComponent, type: :component do
  let(:application_form) { create(:application_form, :submitted) }
  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, providers: [provider]) }

  describe 'with draft and submitted applications' do
    it 'only renders submitted applications' do
      create(:application_choice, sent_to_provider_at: 1.day.ago, application_form:)
      create(:application_choice, sent_to_provider_at: nil, application_form:)

      rendered = render_inline(described_class.new(application_form:, provider_user:))

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

      render_inline(described_class.new(application_form:, provider_user:))
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

      rendered = render_inline(described_class.new(application_form:, provider_user:))

      expect(rendered).to have_css('h3', text: 'Application 1')
      expect(rendered).to have_css('h3', text: 'Application 2')
    end
  end

  describe 'rendered rows' do
    let(:component) { described_class.new(application_form: create(:application_form, :completed, submitted_application_choices_count: 1), provider_user:) }

    it 'renders the course subject' do
      render_inline(component)

      expect(page).to have_text('Subject')
      expect(page).to have_text('Location')
      expect(page).to have_text('Qualification')
      expect(page).to have_text('Funding type')
      expect(page).to have_text('Full time or part time')
      expect(page).to have_text('Date submitted')
      expect(page).to have_no_text('Provider')
      expect(page).to have_no_text('Application number')
      expect(page).to have_no_text('Status')
      expect(page).to have_no_text('Rejection reason')
      expect(page).to have_no_text('Withdrawal reason')
    end
  end

  describe 'rendered rows with choice made to provider' do
    let(:course) { create(:course, provider:) }
    let(:course_option) { create(:course_option, course:) }
    let!(:application_choice) { create(:application_choice, course_option:, application_form:, status: 'withdrawn') }

    it 'renders expected content for provider-facing choice' do
      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_text('Subject')
      expect(page).to have_text('Location')
      expect(page).to have_text('Qualification')
      expect(page).to have_text('Funding type')
      expect(page).to have_text('Full time or part time')
      expect(page).to have_text('Date submitted')
      expect(page).to have_text('Provider')
      expect(page).to have_text('Application number')
      expect(page).to have_text('Status')
      expect(page).to have_text('Withdrawal reason')
    end
  end

  context 'when the application choice is withdrawn with nested published withdrawal reasons and a comment' do
    let(:course) { create(:course, provider:) }
    let(:course_option) { create(:course_option, course:) }
    let(:provider_user) { create(:provider_user, providers: [provider]) }

    let!(:published_reason) do
      create(:withdrawal_reason,
             status: 'published',
             reason: 'applying_to_another_provider.personal_circumstances_have_changed.other',
             comment: 'My circumstances changed')
    end

    let!(:application_choice) do
      create(
        :application_choice,
        :withdrawn,
        course_option:,
        application_form: create(:application_form),
        published_withdrawal_reasons: [published_reason],
      )
    end

    it 'renders the nested withdrawal reason labels with comment interpolation' do
      render_inline(described_class.new(application_form: application_choice.application_form, provider_user: provider_user))

      expect(page).to have_text('I am going to apply (or have applied) to a different training provider because my personal circumstances have changed:')
      expect(page).to have_text('"My circumstances changed"')
    end
  end

  context 'when the application choice is withdrawn with an old structured withdrawal reason' do
    let(:course) { create(:course, provider:) }
    let(:course_option) { create(:course_option, course:) }
    let!(:application_choice) do
      create(:application_choice,
             :withdrawn,
             course_option:,
             application_form:,
             structured_withdrawal_reasons: ['applying_to_different_course_same_provider'])
    end

    it 'renders the old model withdrawal reason label' do
      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_text('I’m going to apply (or have applied) to a different course at the same training provider')
    end
  end

  context 'when the application choice is withdrawn with no reason' do
    let(:course) { create(:course, provider:) }
    let(:course_option) { create(:course_option, course:) }
    let!(:application_choice) do
      create(:application_choice,
             :withdrawn,
             course_option:,
             application_form:)
    end

    it 'renders the old model withdrawal reason label' do
      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_text('No reason given')
    end
  end

  context 'when the application choice is rejected with a nested reason and a comment' do
    let(:course) { create(:course, provider:) }
    let(:course_option) { create(:course_option, course:) }

    let!(:application_choice) do
      create(:application_choice,
             :rejected,
             course_option:,
             application_form:,
             structured_rejection_reasons: {
               selected_reasons: [
                 {
                   id: 'personal_statement',
                   label: 'Personal statement',
                   selected_reasons: [
                     {
                       id: 'quality_of_writing',
                       label: 'Quality of writing',
                       details: { text: 'Too many grammar mistakes' },
                     },
                   ],
                 },
               ],
             })
    end

    it 'renders the category and reason label combined, with comment below' do
      render_inline(described_class.new(application_form:, provider_user:))

      expect(page).to have_text('Personal statement - Quality of writing')
      expect(page).to have_text('"Too many grammar mistakes"')
    end
  end
end

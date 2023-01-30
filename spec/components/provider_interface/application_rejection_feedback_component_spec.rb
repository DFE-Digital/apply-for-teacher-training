require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationRejectionFeedbackComponent do
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
  let(:render) { render_inline described_class.new(application_choice:) }

  context 'when the application is not rejected' do
    it 'does not render' do
      expect(render.to_html).to be_blank
    end
  end

  context 'when the application is rejected but has no feedback' do
    let(:application_choice) { create(:application_choice, :rejected_by_default) }

    it 'does not render' do
      expect(render.to_html).to be_blank
    end
  end

  context 'when the application is rejected with legacy structured reasons' do
    let(:application_choice) do
      create(
        :application_choice,
        :with_old_structured_rejection_reasons,
        rejected_by_default: false,
        reject_by_default_feedback_sent_at: nil,
        rejected_at: 1.day.ago,
      )
    end

    it 'renders the date of rejection' do
      expect(render.text).to include("This application was rejected on #{application_choice.rejected_at.to_fs(:govuk_date)}")
    end

    it 'renders the reasons for rejection' do
      expect(render.css('.govuk-body').text).to include('The following feedback was sent to the candidate')
      expect(render.css('.app-rejection').text).to include('Persistent scratching')
      expect(render.css('.app-rejection').text).to include('Lights on but nobody home')
    end
  end

  context 'when the application is rejected with current structured reasons' do
    let(:application_choice) do
      create(
        :application_choice,
        :with_structured_rejection_reasons,
        rejected_by_default: false,
        reject_by_default_feedback_sent_at: nil,
        rejected_at: 1.day.ago,
      )
    end

    before do
      # Add back in a reason that no longer exists
      application_choice.structured_rejection_reasons['selected_reasons'] << {
        id: 'references', label: 'References',
        details: {
          id: 'references_details',
          text: 'We do not accept references from close family members, such as your mum.',
        }
      }
      application_choice.save!
    end

    it 'renders the date of rejection' do
      expect(render.text).to include("This application was rejected on #{application_choice.rejected_at.to_fs(:govuk_date)}")
    end

    it 'renders the reasons for rejection' do
      expect(render.css('.govuk-body').text).to include('The following feedback was sent to the candidate')
      rows = render.css('.govuk-summary-list__row').map(&:text).map(&:strip)

      expect(rows[0]).to include('Qualifications')
      expect(rows[0]).to include('No maths GCSE at minimum grade 4 or C, or equivalent')
      expect(rows[0]).to include('No English GCSE at minimum grade 4 or C, or equivalent')
      expect(rows[0]).to include('No science GCSE at minimum grade 4 or C, or equivalent')
      expect(rows[0]).to include('No bachelor’s degree or equivalent')
      expect(rows[0]).to include('Could not verify qualifications:')
      expect(rows[0]).to include('We could find no record of your GCSEs')

      expect(rows[1]).to include('Personal statement')
      expect(rows[1]).to include('Quality of writing')
      expect(rows[1]).to include('We do not accept applications written in Old Norse.')

      expect(rows[2]).to include('Course full')
      expect(rows[2]).to include('The course is full.')

      expect(rows[3]).to include('Other')
      expect(rows[3]).to include('So many other things were wrong...')

      expect(rows[4]).to include('References')
      expect(rows[4]).to include('We do not accept references from close family members, such as your mum.')
    end
  end

  context 'when the application is rejected automatically with structured reasons added' do
    let(:application_choice) do
      create(
        :application_choice,
        :with_old_structured_rejection_reasons,
        rejected_at: 1.day.ago,
        reject_by_default_feedback_sent_at: Time.zone.now,
      )
    end

    it 'renders the date of rejection' do
      expect(render.text).to include("This application was automatically rejected on #{application_choice.rejected_at.to_fs(:govuk_date)}")
    end

    it 'renders the date of feedback sent' do
      expect(render.text).to include("Feedback was sent on #{(application_choice.rejected_at + 1.day).to_fs(:govuk_date)}")
    end

    it 'renders the reasons for rejection' do
      expect(render.css('.app-rejection').text).to include('Persistent scratching')
      expect(render.css('.app-rejection').text).to include('Lights on but nobody home')
    end
  end

  context 'when the application is rejected with no structured rejection reasons' do
    let(:application_choice) do
      create(
        :application_choice,
        :rejected,
        rejected_at: 1.day.ago,
      )
    end

    it 'renders a row with the rejection date' do
      rejected_at_row = find_summary_row('Rejected')
      expect(rejected_at_row.text).to include(application_choice.rejected_at.to_fs(:govuk_date))
    end

    it 'renders a row with the rejection reason' do
      rejection_reason_row = find_summary_row('Feedback for candidate')
      expect(rejection_reason_row.text).to include(application_choice.rejection_reason)
    end
  end

  context 'when the application is rejected automatically with no structured rejection reasons' do
    let(:application_choice) do
      create(
        :application_choice,
        :rejected_by_default_with_feedback,
        rejected_at: 1.day.ago,
        reject_by_default_feedback_sent_at: Time.zone.now,
      )
    end

    it 'renders a row with the rejection date' do
      rejected_at_row = find_summary_row('Automatically rejected')
      expect(rejected_at_row.text).to include(application_choice.rejected_at.to_fs(:govuk_date))
    end

    it 'renders a row with the rejection feedback sent date' do
      rejection_feedback_sent_at_row = find_summary_row('Feedback sent')
      expect(rejection_feedback_sent_at_row.text).to include((application_choice.rejected_at + 1.day).to_fs(:govuk_date))
    end

    it 'renders a row with the rejection reason' do
      rejection_reason_row = find_summary_row('Feedback for candidate')
      expect(rejection_reason_row.text).to include(application_choice.rejection_reason)
    end
  end

  def find_summary_row(label)
    render.css('.govuk-summary-list__row').find { |row| row.text.include?(label) }
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::AdditionalRefereesStartComponent do
  let(:application_form) { create(:completed_application_form, references_count: 0, with_gces: true) }

  context 'when one referee request failed' do
    before do
      create(:reference, :complete, application_form: application_form)
    end

    it 'has a page content that requests one new referee' do
      create(:reference, :email_bounced, application_form: application_form)
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-heading-xl').text).to include('You need to add a new referee')
      expect(result.css('.govuk-button').text).to include('Add a new referee')
      expect(result.css('.govuk-link').text).to include('Continue without adding a new referee')
    end

    it 'gives a reason when email bounced' do
      bounced_referee = create(:reference, :email_bounced, application_form: application_form)
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-body').text).to include("Our email requesting a reference didn’t reach #{bounced_referee.name}.")
    end

    it 'gives a reason when referee refused to give feedback' do
      refused_referee = create(:reference, :refused, application_form: application_form)
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-body').text).to include("#{refused_referee.name} said they won’t give a reference.")
    end

    it 'gives a reason when the feedback is overdue' do
      late_referee = create(:reference, :requested, application_form: application_form)
      late_referee.update!(requested_at: Time.zone.now - 30.days)
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-body').text).to include("#{late_referee.name} did not respond to our request.")
    end

    it 'does not show a reference that does not need replacing' do
      create(:reference, :email_bounced, application_form: application_form)
      first_referee = application_form.application_references.first

      result = render_inline(described_class, application_form: application_form)
      expect(result.css('.govuk-body').text).not_to include(first_referee.name.to_s)
    end
  end

  context 'when multiple referee request failed' do
    before do
      create(:reference, :email_bounced, application_form: application_form)
      create(:reference, :refused, application_form: application_form)
      create(:reference, :complete, application_form: application_form)
    end

    it 'has a page content that requests new referees' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-heading-xl').text).to include('You need to add 2 new referees')
      expect(result.css('.govuk-button').text).to include('Add new referees')
      expect(result.css('.govuk-link').text).to include('Continue without adding new referees')
    end

    it 'gives a reason for all failed referee requests' do
      first_referee = application_form.application_references.first
      second_referee = application_form.application_references.second
      third_referee = application_form.application_references.third
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-body').text).to include('Your referees have not given us a reference:')
      expect(result.css('.govuk-body').text).to include("Our email requesting a reference didn’t reach #{first_referee.name}")
      expect(result.css('.govuk-body').text).to include("#{second_referee.name} said they won’t give a reference")
      expect(result.css('.govuk-body').text).not_to include(third_referee.name.to_s)
    end
  end
end

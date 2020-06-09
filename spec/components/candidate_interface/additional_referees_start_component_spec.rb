require 'rails_helper'

RSpec.describe CandidateInterface::AdditionalRefereesStartComponent do
  let(:application_form) { build_stubbed(:completed_application_form, references_count: 0, with_gces: true) }
  let(:reference) { build_stubbed(:reference, :complete, application_form: application_form) }
  let(:references) { [] }

  before { allow(application_form).to receive(:application_references).and_return(references) }

  context 'when one referee request bounced' do
    let(:bounced_referee) { build_stubbed(:reference, :email_bounced, application_form: application_form) }
    let(:references) { [reference, bounced_referee] }

    it 'has a page content that requests one new referee' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-heading-xl').text).to include('You need to add a new referee')
      expect(result.css('.govuk-button').text).to include('Add a new referee')
      expect(result.css('.govuk-link').text).to include('Continue without adding a new referee')
    end

    it 'gives a reason when email bounced' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-body').text).to include("Our email requesting a reference did not reach #{bounced_referee.name}.")
    end
  end

  context 'when one referee refused' do
    let(:refused_referee) { build_stubbed(:reference, :refused, application_form: application_form) }
    let(:references) { [reference, refused_referee] }

    it 'gives a reason why referee refused' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-body').text).to include("#{refused_referee.name} said they will not give a reference.")
    end
  end

  context 'when feedback is overdue' do
    let(:late_referee) { build_stubbed(:reference, :requested, application_form: application_form) }
    let(:references) { [reference, late_referee] }

    it 'gives a reason that feedback is overdue' do
      allow(late_referee).to receive(:requested_at).and_return(Time.zone.now - 30.days)
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-body').text).to include("#{late_referee.name} did not respond to our request.")
      expect(result.css('.govuk-body').text).to include("Adding a new referee will not prevent #{late_referee.name} from giving a reference.")
    end
  end

  context 'when one valid reference exists' do
    let(:failed_reference) { build_stubbed(:reference, :email_bounced, application_form: application_form) }
    let(:references) { [reference, failed_reference] }

    it 'does not show a reference that does not need replacing' do
      first_referee = application_form.application_references.first

      result = render_inline(described_class.new(application_form: application_form))
      expect(result.css('.govuk-body').text).not_to include(first_referee.name.to_s)
    end
  end

  context 'when multiple referee request failed' do
    let(:references) do
      [
        build_stubbed(:reference, :email_bounced, application_form: application_form),
        build_stubbed(:reference, :refused, application_form: application_form),
        build_stubbed(:reference, :complete, application_form: application_form),
      ]
    end

    it 'has a page content that requests a new referee' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-heading-xl').text).to include('You need to add a new referee')
      expect(result.css('.govuk-button').text).to include('Add a new referee')
      expect(result.css('.govuk-link').text).to include('Continue without adding a new referee')
    end

    it 'gives a reason for all failed referee requests' do
      first_referee = application_form.application_references.first
      second_referee = application_form.application_references.second
      third_referee = application_form.application_references.third
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-body').text).to include('Your referees have not given us a reference:')
      expect(result.css('.govuk-body').text).to include("Our email requesting a reference did not reach #{first_referee.name}")
      expect(result.css('.govuk-body').text).to include("#{second_referee.name} said they will not give a reference")
      expect(result.css('.govuk-body').text).not_to include(third_referee.name.to_s)
    end
  end

  context 'when mulitple references are overdue' do
    let(:late_referee) { build_stubbed(:reference, :requested, application_form: application_form) }
    let(:late_referee2) { build_stubbed(:reference, :requested, application_form: application_form) }

    let(:references) { [late_referee, late_referee2] }

    it 'gives a reason that feedback is overdue' do
      allow(late_referee).to receive(:requested_at).and_return(Time.zone.now - 30.days)
      allow(late_referee2).to receive(:requested_at).and_return(Time.zone.now - 30.days)
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-body').text).to include("#{late_referee.name} did not respond to our request. Add a new referee as soon as possible.")
      expect(result.css('.govuk-body').text).to include("#{late_referee2.name} did not respond to our request. Add a new referee as soon as possible.")
      expect(result.css('.govuk-body').text).to include("Adding a new referee will not prevent #{late_referee.name} and #{late_referee2.name} from giving a reference.")
    end
  end
end

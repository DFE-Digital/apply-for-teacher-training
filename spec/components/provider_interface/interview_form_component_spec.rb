require 'rails_helper'

RSpec.describe ProviderInterface::InterviewFormComponent do
  let(:interview_preferences) { nil }
  let(:application_form) { build_stubbed(:application_form, interview_preferences: interview_preferences) }
  let(:application_choice) { build_stubbed(:submitted_application_choice, application_form: application_form) }

  let(:form_object_class) do
    Class.new do
      include ActiveModel::Model
      attr_accessor :time, :date, :location, :additional_details, :provider_id
    end
  end
  let(:form_object) { FormObjectClass.new }

  let(:component) do
    described_class.new(
      application_choice: application_choice,
      form_model: form_object,
      form_url: '',
      form_heading: 'Heading',
    )
  end
  let(:render) { render_inline(component) }

  before do
    stub_const('FormObjectClass', form_object_class)
  end

  it 'renders the title' do
    expect(render.css('h1').first.text).to eq('Heading')
  end

  describe 'interview preferences' do
    context 'when there are interview preferences given' do
      let(:interview_preferences) { 'I use a wheelchair' }

      it 'renders the preferences' do
        expect(render.css('.app-banner > h2').first.text).to eq('Candidate interview preferences')
        expect(render.css('.app-banner > p').first.text).to eq('I use a wheelchair')
      end
    end

    context 'when there are no interview preferences' do
      let(:interview_preferences) { nil }

      it 'does not render any preferences' do
        expect(render.css('.app-banner')).to be_empty
      end
    end
  end

  describe '#example_date' do
    around do |example|
      Timecop.freeze(2021, 11, 1) { example.run }
    end

    context 'reject by default is today' do
      let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: Time.zone.local(2021, 11, 1)) }

      it 'returns today’s date' do
        expect(component.example_date).to eq('1 11 2021')
      end
    end

    context 'reject by default is at least one day in the future' do
      let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: Time.zone.local(2021, 11, 5)) }

      it 'returns tomorrow’s date' do
        expect(component.example_date).to eq('2 11 2021')
      end
    end

    it 'renders the hint text correctly' do
      expect(render.css('.govuk-hint').first.text).to eq('For example, 2 11 2021')
    end
  end

  context 'when there are multiple providers for an application' do
    let(:application_choice) do
      application_choice = build_stubbed(:submitted_application_choice)
      allow(application_choice).to receive(:provider).and_return(build_stubbed(:provider))
      allow(application_choice).to receive(:accredited_provider).and_return(build_stubbed(:provider))
      application_choice
    end

    it 'renders a list of providers as radio buttons' do
      expect(render.css('.govuk-radios > .govuk-radios__item').count).to eq(2)
    end
  end
end

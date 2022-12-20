require 'rails_helper'

RSpec.describe SampleApplicationsFactory do
  describe '.generate_basic_applications(count, provider:)' do
    subject(:applications) { described_class.generate_basic_applications(count, provider:) }

    let(:count) { 3 }
    let(:provider) { create(:provider) }

    before do
      2.times do
        course = create(:course, :open_on_apply, provider:)
        create(:course_option, course:)
      end
    end

    it 'returns n `ApplicationForm`s' do
      expect(applications.count).to eq(count)
      expect(applications).to all(be_an(ApplicationForm))
    end

    it 'creates an `awaiting_provider_decision` application choice for each form, with a course from the training provider' do
      applications.each do |application|
        expect(application.application_choices.count).to eq(1)
        expect(application.application_choices.first.course.provider).to eq(provider)
        expect(application.application_choices.first).to be_awaiting_provider_decision
      end
    end
  end

  describe '.generate_applications(**options)' do
    subject(:applications) do
      described_class.generate_applications(**options)
    end

    let(:options) do
      {
        application_form_count:,
        application_choice_count:,
      }
    end

    before do
      provider = create(:provider)

      2.times do
        course = create(:course, :open_on_apply, provider:)
        create(:course_option, course:)
      end
    end

    context 'when a specific number of applications are requested' do
      let(:application_form_count) { 3 }
      let(:application_choice_count) { 2 }

      it 'returns the requested set of `ApplicationForm`s' do
        expect(applications.count).to eq(application_form_count)
        expect(applications).to all(be_an(ApplicationForm))
        applications.each do |application|
          expect(application.application_choices.count).to eq(application_choice_count)
        end
      end
    end

    context 'when more than 3 application choices are requested' do
      let(:application_form_count) { 3 }
      let(:application_choice_count) { 4 }

      it 'raises an error' do
        expect { applications }.to raise_error(ArgumentError, 'appplication_choice_count cannot be greater than 3')
      end
    end
  end
end

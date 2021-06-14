require 'rails_helper'

RSpec.describe VendorAPI::GenerateTestApplicationsForProvider, sidekiq: true do
  let(:provider) { create(:provider) }
  let(:courses_per_application) { 3 }
  let(:application_count) { 1 }
  let(:for_training_courses) { false }
  let(:for_ratified_courses) { false }
  let(:for_test_provider_courses) { false }
  let(:service_params) do
    {
      provider: provider,
      courses_per_application: courses_per_application,
      count: application_count,
      for_training_courses: for_training_courses,
      for_ratified_courses: for_ratified_courses,
      for_test_provider_courses: for_test_provider_courses,
    }
  end

  before do
    create(:course_option)
    3.times do
      create(:course_option, course: create(:course, :open_on_apply, provider: provider))
    end
    3.times do
      create(:course_option, course: create(:course, :open_on_apply, accredited_provider: provider))
    end
  end

  describe '#call' do
    context 'when count is more than 1' do
      let(:application_count) { 2 }

      it 'generates the correct number of application forms to the correct courses' do
        described_class.new(service_params).call

        choices = provider.application_choices
        expect(choices.map(&:application_form).uniq.count).to eq(2)
        expect(choices.map(&:course).map(&:provider).uniq).to eq([provider])
      end
    end

    context 'when all of for_training_courses, for_ratifying_courses and for_test_provider_courses are false' do
      it 'generates applications to courses run by the provider' do
        described_class.new(service_params).call

        choices = provider.application_choices.last.application_form.application_choices
        training_providers = choices.map(&:provider).compact.uniq

        expect(choices.count).to eq(3)
        expect(training_providers).to contain_exactly(provider)
      end
    end

    context 'when all of for_training_courses, for_ratifying_courses and for_test_provider_courses are true' do
      let(:for_training_courses) { true }
      let(:for_ratified_courses) { true }
      let(:for_test_provider_courses) { true }

      it 'generates applications to a test provider course, and courses run and ratified by the provider' do
        described_class.new(service_params).call

        choices = provider.application_choices.last.application_form.application_choices
        training_providers = choices.map(&:provider).compact
        accredited_providers = choices.map(&:accredited_provider).compact

        expect(choices.count).to eq(3)
        expect(training_providers.map(&:code)).to include(provider.code, 'TEST')
        expect(accredited_providers).to include(provider)
      end
    end

    context 'when for_training_courses is true' do
      let(:for_training_courses) { true }

      it 'generates applications to courses run by the provider' do
        described_class.new(service_params).call

        choices = provider.application_choices.last.application_form.application_choices
        training_providers = choices.map(&:provider).compact.uniq

        expect(choices.count).to eq(3)
        expect(training_providers).to contain_exactly(provider)
      end
    end

    context 'when for_ratified_courses is true' do
      let(:for_ratified_courses) { true }

      it 'generates applications to courses ratified by the provider' do
        described_class.new(service_params).call

        choices = provider.accredited_courses.flat_map(&:application_choices).last.application_form.application_choices
        accredited_providers = choices.map(&:accredited_provider).compact.uniq

        expect(choices.count).to eq(3)
        expect(accredited_providers).to contain_exactly(provider)
      end
    end

    context 'when for_test_provider_courses is true' do
      let(:for_test_provider_courses) { true }

      it 'generates applications to courses run by the test provider' do
        described_class.new(service_params).call

        test_provider = Provider.find_by(code: 'TEST')
        choices = test_provider.application_choices.last.application_form.application_choices
        providers = choices.map(&:provider).compact.uniq

        expect(choices.count).to eq(3)
        expect(providers).to contain_exactly(test_provider)
      end
    end

    describe 'raises an error' do
      it 'when a request is made for zero courses per application' do
        expect {
          described_class.new(
            provider: create(:provider),
            courses_per_application: 0,
            count: 1,
          ).call
        }.to raise_error ParameterInvalid, 'Parameter is invalid (cannot be zero): courses_per_application'
      end

      it 'when a request is made for more courses than exist' do
        expect {
          described_class.new(
            provider: create(:provider),
            courses_per_application: 2,
            count: 1,
          ).call
        }.to raise_error ParameterInvalid, 'Parameter is invalid (cannot be greater than number of available courses): courses_per_application'
      end
    end
  end
end

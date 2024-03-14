require 'rails_helper'

RSpec.describe GenerateTestApplicationsForProvider, :sidekiq do
  let(:provider) { create(:provider) }
  let(:courses_per_application) { 3 }
  let(:application_count) { 1 }
  let(:for_training_courses) { false }
  let(:for_ratified_courses) { false }
  let(:for_test_provider_courses) { false }
  let(:previous_cycle) { false }
  let(:service_params) do
    {
      provider:,
      courses_per_application:,
      count: application_count,
      for_training_courses:,
      for_ratified_courses:,
      for_test_provider_courses:,
      previous_cycle:,
    }
  end

  before do
    training_provider = create(:provider)
    3.times { create(:course_option, course: create(:course, :open, provider:)) }
    3.times { create(:course_option, course: create(:course, :open, provider: training_provider, accredited_provider: provider)) }
    3.times { create(:course_option, course: create(:course, :previous_year, provider:)) }
  end

  describe '#call' do
    context 'when count is more than 1' do
      let(:application_count) { 2 }

      it 'generates the correct number of application forms to the correct courses' do
        described_class.new(**service_params).call

        choices = provider.application_choices

        expect(choices.map(&:application_form).uniq.count).to eq(2)
        expect(choices.map(&:course).map(&:provider).uniq).to eq([provider])
      end
    end

    context 'when all of for_training_courses, for_ratifying_courses and for_test_provider_courses are false' do
      it 'generates applications to courses run by the provider' do
        described_class.new(**service_params).call

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
        described_class.new(**service_params).call

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
        described_class.new(**service_params).call

        choices = provider.application_choices.last.application_form.application_choices
        training_providers = choices.map(&:provider).compact.uniq

        expect(choices.count).to eq(3)
        expect(training_providers).to contain_exactly(provider)
      end
    end

    context 'when for_ratified_courses is true' do
      let(:for_ratified_courses) { true }

      it 'generates applications to courses ratified by the provider' do
        described_class.new(**service_params).call

        choices = provider.accredited_courses.flat_map(&:application_choices).last.application_form.application_choices
        accredited_providers = choices.map(&:accredited_provider).compact.uniq

        expect(choices.count).to eq(3)
        expect(accredited_providers).to contain_exactly(provider)
      end
    end

    context 'when for_test_provider_courses is true' do
      let(:for_test_provider_courses) { true }

      it 'generates applications to courses run by the test provider' do
        described_class.new(**service_params).call

        test_provider = Provider.find_by(code: 'TEST')
        choices = test_provider.application_choices.last.application_form.application_choices
        providers = choices.map(&:provider).compact.uniq

        expect(choices.count).to eq(3)
        expect(providers).to contain_exactly(test_provider)
      end
    end

    context 'when previous_cycle is true' do
      let(:previous_cycle) { true }

      it 'generates applications to courses in the previous recruitment cycle' do
        described_class.new(**service_params).call
        choices = provider.application_choices.last.application_form.application_choices

        expect(choices.count).to eq(3)

        # The old generator does something weird leading to a withdrawn application
        # despite it not being in the states list of `GenerateTestApplicationsForCourses`.
        if FeatureFlag.active?(:sample_applications_factory)
          expect(choices.map(&:status).uniq).to include('pending_conditions', 'awaiting_provider_decision')
        else
          expect(choices.map(&:status).uniq).to include('pending_conditions', 'withdrawn')
        end
        expect(choices.pluck(:current_recruitment_cycle_year).uniq).to eq([RecruitmentCycle.previous_year])
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

      it 'when the service is run in production' do
        ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
          expect {
            described_class.new(**service_params).call
          }.to raise_error('This is not meant to be run in production')
        end
      end
    end
  end
end

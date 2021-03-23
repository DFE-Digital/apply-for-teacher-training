require 'rails_helper'

RSpec.describe VendorAPI::GenerateTestApplicationsForProvider, sidekiq: true do
  describe '#call' do
    it 'generates applications to courses the provider runs' do
      provider = create(:provider)
      create(:course_option)
      # rubocop:disable FactoryBot/CreateList
      3.times do
        create(:course_option, course: create(:course, :open_on_apply, provider: provider))
      end
      # rubocop:enable FactoryBot/CreateList

      described_class.new.call(
        provider: provider,
        courses_per_application: 3,
        count: 2,
      )

      choices = provider.application_choices
      expect(choices.map(&:application_form).uniq.count).to eq(2)
      expect(choices.map(&:course).map(&:provider).uniq).to eq([provider])
    end

    it 'can generate applications to courses the provider ratifies' do
      provider = create(:provider)
      create(:course_option)
      create(:course_option, course: create(:course, provider: provider))
      # rubocop:disable FactoryBot/CreateList
      3.times do
        create(:course_option, course: create(:course, accredited_provider: provider))
      end
      # rubocop:enable FactoryBot/CreateList

      described_class.new.call(
        provider: provider,
        courses_per_application: 3,
        count: 2,
        for_ratified_courses: true,
      )

      choices = provider.accredited_courses.flat_map(&:application_choices)
      expect(choices.map(&:application_form).uniq.count).to eq(2)
      expect(choices.map(&:course).map(&:accredited_provider).uniq).to eq([provider])
    end

    describe 'raises an error' do
      it 'when a request is made for zero courses per application' do
        expect {
          described_class.new.call(
            provider: create(:provider),
            courses_per_application: 0,
            count: 1,
          )
        }.to raise_error ParameterInvalid, 'Parameter is invalid (cannot be zero): courses_per_application'
      end

      it 'when a request is made for more courses than exist' do
        provider = create(:provider)
        create(:course_option, course: create(:course, :open_on_apply, provider: provider))

        expect {
          described_class.new.call(
            provider: provider,
            courses_per_application: 2,
            count: 1,
          )
        }.to raise_error ParameterInvalid, 'Parameter is invalid (cannot be greater than number of available courses): courses_per_application'
      end
    end
  end
end

require 'rails_helper'

RSpec.describe TestProvider do
  describe '.find_or_create' do
    context 'when the provider does not exist' do
      it 'creates and returns a provider with code TEST' do
        existing_test_provider = Provider.find_by(code: 'TEST')
        test_provider = described_class.find_or_create

        expect(existing_test_provider).to be_nil
        expect(test_provider.code).to eq('TEST')
        expect(test_provider.name).to eq('Test Provider')
      end
    end

    context 'when the provider exists' do
      let!(:test_provider) { create(:provider, code: 'TEST') }

      it 'returns the provider with code TEST' do
        expect(described_class.find_or_create).to eq(test_provider)
      end
    end
  end

  describe '.training_courses' do
    let!(:test_provider) { create(:provider, code: 'TEST') }
    let(:previous_cycle) { false }

    context 'when there are 3 or more existing open courses with course options' do
      let!(:test_provider_courses) do
        create_list(:course_option, 3, course: create(:course, :open, provider: test_provider)).map(&:course)
      end
      let!(:test_provider_courses_without_options) do
        create(:course, :open, provider: test_provider)
      end

      it 'returns the list of courses run by the training provider' do
        expect(described_class.training_courses(previous_cycle)).to match_array(test_provider_courses)
      end
    end

    context 'when there are fewer than 3 existing open courses' do
      let!(:test_provider_courses) do
        create(:course, :open, provider: test_provider)
        create_list(:course, 3, :open, :previous_year, provider: test_provider)
        create_list(:course, 3, provider: test_provider)
      end

      it 'creates and returns open courses for the current year' do
        courses = described_class.training_courses(previous_cycle)

        expect(courses.count).to be >= 3
        expect(courses.previous_cycle).to be_empty
      end
    end

    context 'when there are 3 or more courses with course options in the previous cycle' do
      let(:previous_cycle) { true }
      let!(:test_provider_courses) do
        create_list(:course_option, 3, course: create(:course, :previous_year, provider: test_provider)).map(&:course)
      end
      let!(:test_provider_courses_without_options) do
        create(:course, :previous_year, provider: test_provider)
      end

      it 'returns the list of courses run by the training provider' do
        expect(described_class.training_courses(previous_cycle)).to match_array(test_provider_courses)
      end
    end

    context 'when there are fewer than 3 courses in the previous cycle' do
      let(:previous_cycle) { true }
      let!(:test_provider_courses) do
        create(:course, :previous_year, provider: test_provider)
        create_list(:course, 3, provider: test_provider)
      end

      it 'creates and returns courses in the previous cycle' do
        courses = described_class.training_courses(previous_cycle)

        expect(courses.count).to be >= 3
        expect(courses.pluck(:recruitment_cycle_year).uniq).to eq([previous_year])
        expect(courses.current_cycle).to be_empty
      end
    end
  end
end

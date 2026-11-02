require 'rails_helper'

RSpec.describe SupportInterface::ProviderCoursesFilter do
  let(:current_year) { RecruitmentCycleTimetable.current_year }
  let(:next_year) { RecruitmentCycleTimetable.next_year }
  let(:provider) { create(:provider) }
  let(:another_provider) { create(:provider) }
  let(:open_course) { create(:course, :open, provider:, name: 'English', exposed_in_find: true) }
  let(:closed_course) { create(:course, :closed, provider:, name: 'English', exposed_in_find: true) }
  let(:unavailable_course) { create(:course, :unavailable, provider:, name: 'Science') }
  let(:next_year_course) { create(:course, :open, recruitment_cycle_year: next_year, provider:, name: 'Mathematics', exposed_in_find: true) }
  let(:another_provider_course) { create(:course, :open, provider: another_provider, name: 'Art and design', exposed_in_find: true) }
  let(:provider_courses) do
    [
      open_course,
      closed_course,
      unavailable_course,
      next_year_course,
    ]
  end
  let(:params) { { provider_id: provider.id } }

  before do
    open_course
    closed_course
    unavailable_course
    next_year_course
    another_provider_course
  end

  describe '#filters' do
    context 'when no filters are applied' do
      it 'returns all filters with no values' do
        filter = described_class.new(params: params)

        expect(filter.filters).to eq(
          [
            {
              type: :checkboxes,
              heading: 'Recruitment cycle',
              name: 'recruitment_cycle',
              options: [next_year, current_year].map do |year|
                {
                  value: year,
                  label: year,
                  checked: false,
                }
              end,
            },
            {
              type: :search,
              heading: 'Course code',
              value: nil,
              name: 'course_code',
            },
            {
              type: :checkboxes,
              heading: 'Course name',
              name: 'course_name',
              options: provider_courses.pluck(:name).uniq.sort.map do |course_name|
                {
                  value: course_name,
                  label: course_name,
                  checked: false,
                }
              end,
            },
            {
              type: :checkboxes,
              heading: 'Status',
              name: 'status',
              options: ['Open', 'Unpublished', 'Closed by provider', 'Hidden in Find'].map do |status|
                {
                  value: status,
                  label: status,
                  checked: false,
                }
              end,
            },
          ],
        )
      end
    end

    context 'when a recruitment cycle filter is applied' do
      it 'returns the recruitment cycle filter with the correct value' do
        filter = described_class.new(params: params.merge(recruitment_cycle: [current_year.to_s]))

        expect(filter.filters.find { |f| f[:name] == 'recruitment_cycle' }).to eq(
          {
            type: :checkboxes,
            heading: 'Recruitment cycle',
            name: 'recruitment_cycle',
            options: [next_year, current_year].map do |year|
              {
                value: year,
                label: year,
                checked: year == current_year,
              }
            end,
          },
        )
      end
    end

    context 'when a course name is applied' do
      it 'returns the course name filter with the correct value' do
        filter = described_class.new(params: params.merge(course_name: ['English']))

        expect(filter.filters.find { |f| f[:name] == 'course_name' }).to eq(
          {
            type: :checkboxes,
            heading: 'Course name',
            name: 'course_name',
            options: provider_courses.pluck(:name).uniq.sort.map do |course_name|
              {
                value: course_name,
                label: course_name,
                checked: course_name == 'English',
              }
            end,
          },
        )
      end
    end

    context 'when a course code filter is applied' do
      it 'returns the course code filter with the correct value' do
        filter = described_class.new(params: params.merge(course_code: open_course.code))

        expect(filter.filters.find { |f| f[:name] == 'course_code' }).to eq(
          {
            type: :search,
            heading: 'Course code',
            value: open_course.code,
            name: 'course_code',
          },
        )
      end
    end

    context 'when a status filter is applied' do
      context 'when the status filter "Open" is applied' do
        it 'returns the status filter with the correct value' do
          filter = described_class.new(params: params.merge(status: ['Open']))

          expect(filter.filters.find { |f| f[:name] == 'status' }).to eq(
            {
              type: :checkboxes,
              heading: 'Status',
              name: 'status',
              options: ['Open', 'Unpublished', 'Closed by provider', 'Hidden in Find'].map do |status|
                {
                  value: status,
                  label: status,
                  checked: status == 'Open',
                }
              end,
            },
          )
        end
      end
    end
  end

  describe '#filter_records' do
    context 'when no filters are applied' do
      it 'returns all courses for the provider' do
        filter = described_class.new(params: params)

        expect(filter.filter_records(provider.courses)).to match_array(provider_courses)
      end
    end

    context 'when a recruitment cycle filter is applied' do
      it 'returns only courses for the provider in the specified recruitment cycle' do
        filter = described_class.new(params: params.merge(recruitment_cycle: [current_year.to_s]))

        expect(filter.filter_records(provider.courses)).to contain_exactly(open_course, closed_course, unavailable_course)
      end
    end

    context 'when a course name filter is applied' do
      it 'returns only courses for the provider with the specified name' do
        filter = described_class.new(params: params.merge(course_name: ['English']))

        expect(filter.filter_records(provider.courses)).to contain_exactly(open_course, closed_course)
      end
    end

    context 'when a course code filter is applied' do
      it 'returns only courses for the provider with the specified code' do
        filter = described_class.new(params: params.merge(course_code: open_course.code))

        expect(filter.filter_records(provider.courses)).to contain_exactly(open_course)
      end
    end

    context 'when a status filter is applied' do
      context 'when the status filter "Open" is applied' do
        it 'returns only courses for the provider with the specified status' do
          filter = described_class.new(params: params.merge(status: ['Open']))

          expect(filter.filter_records(provider.courses)).to contain_exactly(open_course)
        end
      end

      context 'when the status filter "Unpublished" is applied' do
        it 'returns only courses for the provider with the specified status' do
          filter = described_class.new(params: params.merge(status: ['Unpublished']))

          expect(filter.filter_records(provider.courses)).to contain_exactly(next_year_course)
        end
      end

      context 'when the status filter "Closed by provider" is applied' do
        it 'returns only courses for the provider with the specified status' do
          filter = described_class.new(params: params.merge(status: ['Closed by provider']))

          expect(filter.filter_records(provider.courses)).to contain_exactly(closed_course)
        end
      end

      context 'when the status filter "Hidden in Find" is applied' do
        it 'returns only courses for the provider with the specified status' do
          filter = described_class.new(params: params.merge(status: ['Hidden in Find']))

          expect(filter.filter_records(provider.courses)).to contain_exactly(unavailable_course)
        end
      end
    end
  end
end

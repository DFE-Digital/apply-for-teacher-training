require 'rails_helper'

RSpec.describe GetAvailableCoursesForProvider do
  let!(:provider) { create(:provider) }

  describe '#call' do
    it 'returns courses exposed in find in the current cycle' do
      exposed_in_find = create(
        :course,
        exposed_in_find: true,
        provider:,
        name: 'English',
      )
      exposed_in_find_but_not_open = create(
        :course,
        exposed_in_find: true,
        name: 'Math',
        provider:,
        application_status: 'closed',
      )
      _previous_cycle = create(:course, :previous_year, exposed_in_find: true, provider:)

      expect(described_class.new(provider).call).to eq(
        [exposed_in_find, exposed_in_find_but_not_open],
      )
    end
  end

  describe '#courses_for_current_cycle' do
    it 'returns courses in the current cycle' do
      current_cycle = create(:course, provider:)
      _previous_cycle = create(
        :course,
        :previous_year,
        exposed_in_find: true,
      )

      expect(described_class.new(provider).courses_for_current_cycle).to eq([current_cycle])
    end
  end

  describe '#open_courses' do
    it 'returns all open courses in the current cycle' do
      open = create(:course, :open, provider:)
      _closed = create(:course, application_status: 'closed', provider:)
      _closed_exposed_in_find = create(
        :course,
        :unavailable,
        :closed,
        provider:,
      )
      _previous_cycle = create(:course, :open, :previous_year, provider:)

      expect(described_class.new(provider).open_courses).to eq(
        [open],
      )
    end
  end
end

require 'rails_helper'

RSpec.describe OpenAllCoursesOnApplyWorker do
  it 'opens courses that are closed on Apply and in the current cycle' do
    travel_temporarily_to(CycleTimetable.find_opens(2022) + 1.day) do
      open_course = create(:course, :open)
      closed_course = create(:course, open_on_apply: false)
      course_in_the_previous_cycle = create(:course, open_on_apply: false, recruitment_cycle_year: 2021)

      described_class.new.perform

      expect(open_course.reload.open_on_apply).to be true
      expect(course_in_the_previous_cycle.reload.open_on_apply).to be false
      expect(closed_course.reload.open_on_apply).to be true
    end
  end

  it 'sets the opened on apply timestamp' do
    opened_on_apply = CycleTimetable.find_opens(2022) + 2.days

    travel_temporarily_to(opened_on_apply) do
      course = create(:course, open_on_apply: false)
      described_class.new.perform

      expect(course.reload.opened_on_apply_at).to eq(opened_on_apply)
    end
  end

  it 'wont open courses if Apply is not in the new cycle' do
    course = create(:course, open_on_apply: false)

    travel_temporarily_to(CycleTimetable.find_opens(2022) - 1.day) do
      described_class.new.perform
      expect(course.reload.open_on_apply).to be false
    end
  end
end

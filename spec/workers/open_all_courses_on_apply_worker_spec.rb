require 'rails_helper'

RSpec.describe OpenAllCoursesOnApplyWorker do
  it 'opens courses that are closed on Apply and in the current cycle' do
    Timecop.freeze(CycleTimetable.apply_reopens) do
      open_course = create(:course, open_on_apply: true)
      closed_course = create(:course, open_on_apply: false)
      course_in_the_previous_cycle = create(:course, open_on_apply: false, recruitment_cycle_year: RecruitmentCycle.previous_year)

      described_class.new.perform

      expect(open_course.reload.open_on_apply).to eq true
      expect(course_in_the_previous_cycle.reload.open_on_apply).to eq false
      expect(closed_course.reload.open_on_apply).to eq true
    end
  end

  it 'sets the opened on apply timestamp' do
    opened_on_apply = CycleTimetable.apply_reopens + 2.days

    Timecop.freeze(opened_on_apply) do
      course = create(:course, open_on_apply: false)
      described_class.new.perform

      expect(course.reload.opened_on_apply_at).to eq(opened_on_apply)
    end
  end

  it 'wont open courses if Apply is not in the new cycle' do
    course = create(:course, open_on_apply: false)

    Timecop.freeze(CycleTimetable.apply_reopens - 1.day) do
      described_class.new.perform
      expect(course.reload.open_on_apply).to eq false
    end
  end
end

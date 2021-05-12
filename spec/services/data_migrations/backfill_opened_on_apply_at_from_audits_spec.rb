require 'rails_helper'

RSpec.describe DataMigrations::BackfillOpenedOnApplyAtFromAudits, with_audited: true do
  it 'uses the timestamp from last open in audits' do
    course = create(:course)
    last_opened_at = Time.zone.local(2021, 1, 12, 12, 30, 0)

    Timecop.freeze(last_opened_at - 2.minutes) { course.update(open_on_apply: true) }
    Timecop.freeze(last_opened_at - 1.minute) { course.update(open_on_apply: false) }
    Timecop.freeze(last_opened_at) { course.update(open_on_apply: true) }

    described_class.new.change
    expect(course.reload.opened_on_apply_at).to eq(last_opened_at)
  end

  it 'uses the right timestamp for each course' do
    courses = create_list(:course, 2)
    first_opened_at = Time.zone.local(2021, 1, 12, 12, 30, 0)
    second_opened_at = Time.zone.local(2021, 1, 13, 12, 30, 0)

    Timecop.freeze(first_opened_at - 2.days) { courses.first.update(open_on_apply: true) }
    Timecop.freeze(second_opened_at) { courses.second.update(open_on_apply: true) }
    Timecop.freeze(first_opened_at - 1.day) { courses.first.update(open_on_apply: false) }
    Timecop.freeze(first_opened_at) { courses.first.update(open_on_apply: true) }

    described_class.new.change
    expect(courses.first.reload.opened_on_apply_at).to eq(first_opened_at)
    expect(courses.second.reload.opened_on_apply_at).to eq(second_opened_at)
  end

  it 'works with test courses that were open from the start' do
    opened_at = Time.zone.local(2021, 1, 12, 12, 30, 0)

    Timecop.freeze(opened_at) do
      course = create(:course, open_on_apply: true)
      described_class.new.change
      expect(course.reload.opened_on_apply_at).to eq(opened_at)
    end
  end

  it 'uses created_at for courses lacking open_on_apply audits' do
    created_at = Time.zone.local(2020, 2, 10, 12, 0, 0)
    course = create(:course, open_on_apply: true, created_at: created_at)
    course.audits.destroy_all
    described_class.new.change
    expect(course.reload.opened_on_apply_at).to eq(created_at)
  end
end

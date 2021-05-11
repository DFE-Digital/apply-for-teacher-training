require 'rails_helper'

RSpec.describe DataMigrations::BackfillOpenedOnApplyAtFromAudits, with_audited: true do
  it 'uses the timestamp from last open in audits' do
    course = create(:course)
    last_opened_at = Time.zone.local(2021, 1, 12, 12, 30, 0)

    Timecop.freeze(last_opened_at - 2.minutes) { course.update(open_on_apply: true) }
    Timecop.freeze(last_opened_at - 1.minute) { course.update(open_on_apply: false) }
    Timecop.freeze(last_opened_at) { course.update(open_on_apply: true) }
    Timecop.freeze(last_opened_at + 1.minute) { course.update(open_on_apply: false) }

    described_class.new.change
    expect(course.reload.opened_on_apply_at).to eq(last_opened_at)
  end

  it 'works with test courses that were open from the start' do
    opened_at = Time.zone.local(2021, 1, 12, 12, 30, 0)

    Timecop.freeze(opened_at) do
      course = create(:course, open_on_apply: true)
      described_class.new.change
      expect(course.reload.opened_on_apply_at).to eq(opened_at)
    end
  end
end

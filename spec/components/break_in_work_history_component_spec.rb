require 'rails_helper'

RSpec.describe BreakInWorkHistoryComponent do
  it 'shows the correct break between 2 works' do
    jan2019 = Time.zone.local(2019, 1, 1)

    work1 = instance_double(ApplicationWorkExperience, start_date: jan2019, end_date: jan2019 + 2.months)
    work2 = instance_double(ApplicationWorkExperience, start_date: jan2019 + 6.months, end_date: nil)

    component = BreakInWorkHistoryComponent.new(work1: work1, work2: work2)

    expect(render_inline(component).text).to include('You have a break in your work history (3 months)')
  end

  context 'when work1 is the last entry' do
    it 'does not show the break if work1 is the current job)' do
      jan2019 = Time.zone.local(2019, 1, 1)

      work1 = instance_double(ApplicationWorkExperience, start_date: jan2019, end_date: nil)

      component = BreakInWorkHistoryComponent.new(work1: work1, work2: nil)

      expect(render_inline(component).text).to be_empty
    end

    it 'show the correct break between the end of the work1 and current time)' do
      jan2019 = Time.zone.local(2019, 1, 1)

      work1 = instance_double(ApplicationWorkExperience, start_date: jan2019, end_date: jan2019 + 2.months)

      Timecop.freeze(Time.zone.local(2020, 1, 1)) do
        component = BreakInWorkHistoryComponent.new(work1: work1, work2: nil)

        expect(render_inline(component).text).to include('You have a break in your work history (9 months)')
      end
    end
  end
end

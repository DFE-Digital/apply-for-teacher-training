require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverMidCycleComponent do
  it 'renders the component' do
    application_form = build(:completed_application_form)
    result = render_inline(described_class.new(application_form:))

    expect(result.text).to include('Continue your application')
  end

  [RecruitmentCycleTimetable.previous_timetable, RecruitmentCycleTimetable.current_timetable].each do |timetable|
    context "after the new recruitment cycle begins year: #{timetable.recruitment_cycle_year}", time: timetable.apply_opens_at do
      it 'renders the correct academic years' do
        current_year = timetable.recruitment_cycle_year
        application_year = current_year - 1
        application_form = build(:completed_application_form, recruitment_cycle_year: application_year)
        result = render_inline(described_class.new(application_form:))

        expect(result.text).to include("You started an application for courses starting in the #{application_year} to #{application_year + 1} academic year, which have now closed.")
        expect(result.text).to include("Continue your application to apply for courses starting in the #{current_year} to #{current_year + 1} academic year instead.")
      end
    end

    context 'the application was started two years ago', time: timetable.apply_opens_at do
      it 'renders the correct academic years' do
        application_year = timetable.recruitment_cycle_year - 2
        current_year = RecruitmentCycleTimetable.current_year

        application_form = build(:completed_application_form, recruitment_cycle_year: application_year)
        result = render_inline(described_class.new(application_form:))

        expect(result.text).to include("You started an application for courses starting in the #{application_year} to #{application_year + 1} academic year, which have now closed.")
        expect(result.text).to include("Continue your application to apply for courses starting in the #{current_year} to #{current_year + 1} academic year instead.")
      end
    end
  end
end

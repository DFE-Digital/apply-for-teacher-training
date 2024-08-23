require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverMidCycleComponent do
  it 'renders the component' do
    application_form = build(:completed_application_form)
    result = render_inline(described_class.new(application_form:))

    expect(result.text).to include('Continue your application')
  end

  [RecruitmentCycle.previous_year, RecruitmentCycle.current_year, RecruitmentCycle.next_year].each do |year|
    context "after the new recruitment cycle begins year: #{year}", time: CycleTimetable.apply_opens(year) do
      it 'renders the correct academic years' do
        application_form = build(:completed_application_form, recruitment_cycle_year: year - 1)
        result = render_inline(described_class.new(application_form:))

        expect(result.text).to include("You started an application for courses starting in the #{year - 1} to #{year} academic year, which have now closed.")
        expect(result.text).to include("Continue your application to apply for courses starting in the #{year} to #{year + 1} academic year instead.")
      end
    end

    context 'the application was started two years ago', time: CycleTimetable.apply_opens(year) do
      it 'renders the correct academic years' do
        application_form = build(:completed_application_form, recruitment_cycle_year: year - 2)
        result = render_inline(described_class.new(application_form:))

        expect(result.text).to include("You started an application for courses starting in the #{year - 2} to #{year - 1} academic year, which have now closed.")
        expect(result.text).to include("Continue your application to apply for courses starting in the #{year} to #{year + 1} academic year instead.")
      end
    end
  end
end

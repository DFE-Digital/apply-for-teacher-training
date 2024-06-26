require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverInsetTextComponent do
  context 'application is unsuccessful and apply deadline has passed' do
    context 'after the new recruitment cycle begins' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_reopens(2024))
      end

      it 'renders the correct academic years' do
        application_choice = build(:application_choice, :rejected)
        application_form = build(:completed_application_form,
                                 recruitment_cycle_year: RecruitmentCycle.previous_year,
                                 application_choices: [application_choice])
        result = render_inline(described_class.new(application_form:))

        expect(result.text).to include('You submitted your application for courses starting in the 2023 to 2024 academic year, which have now closed.')
        expect(result.text).to include('You can apply for courses starting in the 2024 to 2025 academic year instead.')
      end
    end

    context 'after the apply deadline but before apply reopens' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_deadline(2023))
      end

      it 'renders the correct academic years' do
        application_choice = build(:application_choice, :rejected)
        application_form = build(:completed_application_form,
                                 recruitment_cycle_year: RecruitmentCycle.current_year,
                                 application_choices: [application_choice])

        advance_time_to(after_apply_deadline(2023))
        result = render_inline(described_class.new(application_form:))

        expect(result.text).to include('You submitted your application for courses starting in the 2023 to 2024 academic year, which have now closed.')
        expect(result.text).to include('You can apply for courses starting in the 2024 to 2025 academic year instead.')
        expect(result.css('.govuk-button').first.text).to eq('Apply again')
      end
    end
  end
end

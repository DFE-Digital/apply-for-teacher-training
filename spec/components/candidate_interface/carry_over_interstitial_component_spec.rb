require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverInterstitialComponent do
  it 'renders the component' do
    application_form = build(:completed_application_form)
    result = render_inline(described_class.new(application_form:))

    expect(result.text).to include('Continue your application')
  end

  context 'after the new recruitment cycle begins' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_reopens(2022))
    end

    it 'renders the correct academic years' do
      application_form = build(:completed_application_form, recruitment_cycle_year: 2021)
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include('You started an application for courses starting in the 2021 to 2022 academic year, which have now closed.')
      expect(result.text).to include('Continue your application to apply for courses starting in the 2022 to 2023 academic year instead.')
      expect(result.text).to include('You no longer need to request and receive references before submitting your application.')
      expect(result.text).to include('Instead, you’ll need to give details of 2 people who can give references if you accept a place on a course.')
    end
  end

  context 'after the apply_1 deadline but before apply reopens' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_1_deadline(2021))
    end

    it 'renders the correct academic years' do
      application_form = build(:completed_application_form, recruitment_cycle_year: RecruitmentCycle.current_year)
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include('You started an application for courses starting in the 2021 to 2022 academic year, which have now closed.')
      expect(result.text).to include('Continue your application to apply for courses starting in the 2022 to 2023 academic year instead.')
      expect(result.text).to include('You no longer need to request and receive references before submitting your application.')
      expect(result.text).to include('Instead, you’ll need to give details of 2 people who can give references if you accept a place on a course.')
    end
  end
end

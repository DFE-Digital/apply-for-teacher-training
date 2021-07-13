require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverInterstitialComponent do
  it 'renders the component' do
    application_form = build(:completed_application_form)
    result = render_inline(described_class.new(application_form: application_form))

    expect(result.text).to include('Continue your application')
  end

  context 'after the new recruitment cycle begins' do
    around do |example|
      Timecop.freeze(CycleTimetable.apply_reopens(2022) + 1.day) do
        example.run
      end
    end

    it 'renders the correct academic years' do
      application_form = build(:completed_application_form, recruitment_cycle_year: 2021)
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('You started an application for courses starting in the 2021 to 2022 academic year, which have now closed.')
      expect(result.text).to include('Continue your application to apply for courses starting in the 2022 to 2023 academic year instead.')
    end
  end

  context 'after the apply_1 deadline but before apply reopens' do
    around do |example|
      Timecop.freeze(CycleTimetable.apply_1_deadline(2021) + 1.day) do
        example.run
      end
    end

    it 'renders the correct academic years' do
      application_form = build(:completed_application_form, recruitment_cycle_year: RecruitmentCycle.current_year)
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('You started an application for courses starting in the 2021 to 2022 academic year, which have now closed.')
      expect(result.text).to include('Continue your application to apply for courses starting in the 2022 to 2023 academic year instead.')
    end
  end
end

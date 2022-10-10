require 'rails_helper'

RSpec.describe CandidateInterface::ReviewApplicationComponent do
  context 'when mid cycle' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_1_deadline - 1.day)
    end

    it 'renders the banner with the correct date for when apply reopens' do
      application_form = create(:application_form)
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include('Check and submit your application')
    end
  end

  context 'before the new cycle' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_2_deadline + 1.day)
    end

    it 'renders the banner with the correct date for when apply reopens' do
      application_form = create(:application_form)
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include("You cannot submit your application until 9am on #{CycleTimetable.apply_reopens.to_fs(:govuk_date)}. You can keep making changes to your application until then.")
    end
  end

  context 'after find opens' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.find_reopens + 1.day)
    end

    it 'renders the banner with the correct date for when apply reopens' do
      application_form = create(:application_form)
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include("You cannot submit your application until 9am on #{CycleTimetable.apply_opens.to_fs(:govuk_date)}. You can keep making changes to your application until then.")
    end
  end
end

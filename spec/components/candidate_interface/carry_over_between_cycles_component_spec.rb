require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverBetweenCyclesComponent do
  context 'application choices are not present', time: after_apply_deadline do
    it 'renders the component without information about status changes', :aggregate_failures do
      application_form = build(:application_form)
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include('The application deadline has passed')
      expect(result.text).to include('What happens next')

      next_academic_year = "#{RecruitmentCycle.next_year} to #{RecruitmentCycle.next_year + 1}"
      expect(result.text).to include("You can update your details to get ready to apply for courses starting in the #{next_academic_year} academic year.")

      apply_reopens_date = CycleTimetable.apply_opens(RecruitmentCycle.next_year).to_fs(:govuk_date)
      expect(result.text).to include("You will be able to apply for these courses from #{apply_reopens_date}.")
      expect(result).to have_button('Update your details')

      expect(result.text).not_to include('This means the status of some of your applications might have changed automatically. Please contact the provider for more information about your application.')
    end
  end

  context 'application choices are present', time: after_apply_deadline do
    it 'renders the component without information about status changes' do
      application_form = create(:application_form, application_choices: [build(:application_choice, :rejected)])
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include('The application deadline has passed')
      expect(result.text).to include('What happens next')

      next_academic_year = "#{RecruitmentCycle.next_year} to #{RecruitmentCycle.next_year + 1}"
      expect(result.text).to include("You can update your details to get ready to apply for courses starting in the #{next_academic_year} academic year.")

      apply_reopens_date = CycleTimetable.apply_opens(RecruitmentCycle.next_year).to_fs(:govuk_date)
      expect(result.text).to include("You will be able to apply for these courses from #{apply_reopens_date}.")
      expect(result).to have_button('Update your details')

      expect(result.text).to include('This means the status of some of your applications might have changed automatically. Please contact the provider for more information about your application.')
    end
  end
end

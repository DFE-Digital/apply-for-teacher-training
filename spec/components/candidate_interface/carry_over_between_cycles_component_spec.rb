require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverBetweenCyclesComponent do
  context 'application choices are not present', time: after_apply_deadline do
    it 'renders the component without information about status changes', :aggregate_failures do
      application_form = build(:application_form)
      timetable = application_form.recruitment_cycle_timetable
      result = render_inline(described_class.new(application_form:))

      expect(result).to have_content('The application deadline has passed')
      expect(result).to have_content('What happens next')

      next_academic_year = timetable.next_available_academic_year_range
      expect(result).to have_content("You can update your details to get ready to apply for courses starting in the #{next_academic_year} academic year.")

      apply_reopens_date = timetable.apply_reopens_at.to_fs(:govuk_date)
      expect(result).to have_content("You will be able to apply for these courses from #{apply_reopens_date}.")
      expect(result).to have_button('Update your details')

      expect(result).to have_no_content('This means the status of some of your applications might have changed automatically. Please contact the provider for more information about your application.')
    end
  end

  context 'application choices are present', time: after_apply_deadline do
    it 'renders the component without information about status changes' do
      application_form = create(:application_form, application_choices: [build(:application_choice, :rejected)])
      timetable = application_form.recruitment_cycle_timetable
      result = render_inline(described_class.new(application_form:))

      expect(result).to have_content('The application deadline has passed')
      expect(result).to have_content('What happens next')

      next_academic_year = timetable.relative_next_timetable.academic_year_range_name
      expect(result).to have_content("You can update your details to get ready to apply for courses starting in the #{next_academic_year} academic year.")

      apply_reopens_date = timetable.relative_next_timetable.apply_opens_at.to_fs(:govuk_date)
      expect(result).to have_content("You will be able to apply for these courses from #{apply_reopens_date}.")
      expect(result).to have_button('Update your details')

      expect(result).to have_content('This means the status of some of your applications might have changed automatically. Please contact the provider for more information about your application.')
    end
  end
end

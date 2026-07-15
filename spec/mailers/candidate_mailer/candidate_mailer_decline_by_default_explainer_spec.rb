require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.decline_by_default_explainer' do
    let(:application_form) { create(:completed_application_form) }
    let(:email) { described_class.decline_by_default_explainer(application_form) }
    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:next_academic_year_range) { timetable.next_available_academic_year_range }
    let(:next_recruitment_cycle_year) { timetable.relative_next_year }
    let(:apply_reopens_date) { timetable.apply_reopens_at.to_fs(:govuk_date_time_time_first) }

    it_behaves_like(
      'a mail with subject and content',
      'Your application has been declined automatically',
      'cause' => 'This is because you did not respond before the deadline.',
      'what happens next' => 'What happens next?',
      'sign in' => 'Sign in to your account to update your details',
      'contact us' => 'Contact us',
      'contact details' => 'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
    )

    context 'with one application choice' do
      let(:application_choice) { create(:application_choice, :declined_by_default, application_form:) }
      let(:jan_course) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
      let(:jan_course_option) { create(:course_option, course: jan_course) }
      let(:jan_choice) { create(:application_choice, :declined_by_default, application_form:, course_option: jan_course_option) }

      before do
        application_choice
        jan_choice
      end

      it 'renders content for one application choice' do
        expect(email.body).to include("Dear #{application_form.first_name}")
        expect(email.body).to include(
          'Your offer of a place on the following teacher training course has been declined automatically:',
        )
        expect(email.body).to include(
          "#{application_choice.course.name_and_code} at #{application_choice.provider.name}",
        )
        expect(email.body).not_to include(
          "#{jan_choice.course.name_and_code} at #{jan_choice.provider.name}",
        )
      end
    end

    context 'with many application choices' do
      let(:application_choice_1) { create(:application_choice, :declined_by_default, application_form:) }
      let(:application_choice_2) { create(:application_choice, :declined_by_default, application_form:) }
      let(:jan_course) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
      let(:jan_course_option) { create(:course_option, course: jan_course) }
      let(:jan_choice) { create(:application_choice, :declined_by_default, course_option: jan_course_option) }

      before do
        application_choice_1
        application_choice_2
        jan_choice
      end

      it 'renders content for many application choices' do
        expect(email.body).to include("Dear #{application_form.first_name}")
        expect(email.body).to include(
          'Your offers of places on the following teacher training courses have been declined automatically:',
        )
        expect(email.body).to include(
          "#{application_choice_1.course.name_and_code} at #{application_choice_1.provider.name}",
        )
        expect(email.body).to include(
          "#{application_choice_2.course.name_and_code} at #{application_choice_2.provider.name}",
        )
        expect(email.body).not_to include(
          "#{jan_choice.course.name_and_code} at #{jan_choice.provider.name}",
        )
      end
    end

    it 'renders content for updating the recipients details' do
      expect(email.body).to include(
        "Update your details to get ready to apply for courses starting in the #{next_academic_year_range} academic year.",
      )
    end

    it 'renders content for applying for courses' do
      expect(email.body).to include(
        "You will be able to apply to these courses from #{apply_reopens_date}.",
      )
    end
  end
end

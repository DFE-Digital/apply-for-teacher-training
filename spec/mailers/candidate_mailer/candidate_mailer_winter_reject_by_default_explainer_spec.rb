require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.winter_reject_by_default_explainer' do
    let(:application_form) { create(:completed_application_form) }
    let(:email) { described_class.winter_reject_by_default_explainer(application_form) }
    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:this_academic_year) { timetable.academic_year_range_name }
    let(:next_academic_year) { timetable.next_available_academic_year_range }
    let(:jan_course) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
    let(:jan_course_option) { create(:course_option, course: jan_course) }

    it_behaves_like(
      'a mail with subject and content',
      'Your application has been rejected automatically',
      'what happens next' => 'What happens next?',
      'sign in' => 'Sign in to your account to apply for courses',
      'contact us' => 'Contact us',
      'contact details' => 'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
    )

    context 'with one application choice' do
      let(:application_choice) { create(:application_choice, :rejected_by_default, application_form:) }
      let(:jan_choice) { create(:application_choice, :rejected_by_default, application_form:, course_option: jan_course_option) }

      before do
        application_choice
        jan_choice
      end

      it 'renders content for one application choice' do
        expect(email.body).to include("Dear #{application_form.first_name}")
        expect(email.body).to include(
          "Your application for the following teacher training course has been rejected automatically:",
        )
        expect(email.body).to include(
          "#{jan_choice.course.name_and_code} at #{jan_choice.provider.name}",
        )
        expect(email.body).not_to include(
          "#{application_choice.course.name_and_code} at #{application_choice.provider.name}",
        )
        expect(email.body).to include(
          "This is because the provider did not respond before their deadline. If you have any questions about this, please contact the provider.",
        )
      end
    end

    context 'with many application choices' do
      let(:application_choice) { create(:application_choice, :rejected_by_default, application_form:) }
      let(:jan_choice_1) { create(:application_choice, :rejected_by_default, application_form:, course_option: jan_course_option) }
      let(:jan_course_2) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
      let(:jan_course_option_2) { create(:course_option, course: jan_course_2) }
      let(:jan_choice_2) { create(:application_choice, :rejected_by_default, application_form:, course_option: jan_course_option_2) }

      before do
        application_choice
        jan_choice_1
        jan_choice_2
      end

      it 'renders content for many application choices' do
        expect(email.body).to include("Dear #{application_form.first_name}")
        expect(email.body).to include(
          "Your applications for the following teacher training courses have been rejected automatically:",
        )
        expect(email.body).to include(
          "#{jan_choice_1.course.name_and_code} at #{jan_choice_1.provider.name}",
        )
        expect(email.body).to include(
          "#{jan_choice_2.course.name_and_code} at #{jan_choice_2.provider.name}",
        )
        expect(email.body).not_to include(
          "#{application_choice.course.name_and_code} at #{application_choice.provider.name}",
        )
        expect(email.body).to include(
          "This is because the providers did not respond before their deadline. If you have any questions about this, please contact the providers.",
        )
      end
    end

    it 'renders content for open courses' do
      expect(email.body).to include(
        "You can now apply to courses starting in the #{next_academic_year} academic year.",
      )
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.winter_decline_by_default_explainer' do
    let(:application_form) { create(:completed_application_form) }
    let(:email) { described_class.winter_decline_by_default_explainer(application_form) }
    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:next_timetable) { timetable.relative_next_timetable }
    let(:next_academic_year) { next_timetable.academic_year_range_name }
    let(:apply_reopens_date) { next_timetable.apply_reopens_at.to_fs(:govuk_date_time_time_first) }
    let(:jan_course) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
    let(:jan_course_option) { create(:course_option, course: jan_course) }

    it_behaves_like(
      'a mail with subject and content',
      'Your application has been declined automatically',
      'cause' => 'This is because you did not respond before the deadline.',
      'what happens next' => 'What happens next?',
      'providers make offers' => 'Training providers make offers throughout the year. Providers may close applications early if a course fills up.',
      'courses can close' => 'Courses can fill up quickly, so apply as soon as you are ready. If a course closes, you will need to wait until the next year to apply.',
      'sign in' => 'Sign in to your account to apply for courses',
      'contact us' => 'Contact us',
      'contact details' => 'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
    )

    context 'with one application choice' do
      let(:application_choice) { create(:application_choice, :declined_by_default, application_form:) }
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
          "#{jan_choice.course.name_and_code} at #{jan_choice.provider.name}",
        )
        expect(email.body).not_to include(
          "#{application_choice.course.name_and_code} at #{application_choice.provider.name}",
        )
      end
    end

    context 'with many application choices' do
      let(:application_choice) { create(:application_choice, :declined_by_default, application_form:) }
      let(:jan_choice_1) { create(:application_choice, :declined_by_default, application_form:, course_option: jan_course_option) }
      let(:jan_course_2) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
      let(:jan_course_option_2) { create(:course_option, course: jan_course_2) }
      let(:jan_choice_2) { create(:application_choice, :declined_by_default, application_form:, course_option: jan_course_option_2) }

      before do
        application_choice
        jan_choice_1
        jan_choice_2
      end

      it 'renders content for many application choices' do
        expect(email.body).to include("Dear #{application_form.first_name}")
        expect(email.body).to include(
          'Your offers of places on the following teacher training courses have been declined automatically:',
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
      end
    end

    it 'renders content for updating the recipients details' do
      expect(email.body).to include(
        "You can now apply to courses starting in the #{next_academic_year} academic year.",
      )
    end
  end
end

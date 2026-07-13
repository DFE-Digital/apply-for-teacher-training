require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  let(:email) { described_class.respond_to_offer_before_winter_deadline(application_form) }
  let(:application_form) { create(:completed_application_form) }
  let(:timetable) { application_form.recruitment_cycle_timetable }
  let(:winter_deadline) { timetable.winter_decline_by_default_at.to_fs(:govuk_date_time_time_first) }
  let(:next_recruitment_cycle_year) { timetable.relative_next_year }
  let(:jan_course) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
  let(:jan_course_option) { create(:course_option, course: jan_course) }
  let(:application_choice) { create(:application_choice, :offer, application_form:) }
  let(:jan_choice) { create(:application_choice, :offer, course_option: jan_course_option, application_form:) }

  before { application_choice }

  describe '.respond_to_offer_before_winter_deadline' do
    before { jan_choice }

    context 'with one application choice' do
      it 'renders the content' do
        expect(email.subject).to eq(
          "Accept your place on a teacher training course by #{winter_deadline}",
        )
        expect(email.body).to include("Dear #{application_form.first_name}")
        expect(email.body).to include('You have been offered a place on the following teacher training course:')
        expect(email.body).to include("#{jan_choice.course.name_and_code} at #{jan_choice.provider.name}")
        expect(email.body).not_to include("#{application_choice.course.name_and_code} at #{application_choice.provider.name}")
        expect(email.body).to include("If you want to accept this offer, you must do so by #{winter_deadline}.")
        expect(email.body).to include('Sign in to your account to review your offer')
        expect(email.body).to include('Your other applications')
        expect(email.body).to include(
          "Your other applications for teacher training starting in January #{next_recruitment_cycle_year} have been automatically rejected.",
        )
        expect(email.body).to include(
          'This is because the provider did not respond before their deadline. If you have any questions about this, please contact the provider.',
        )
        expect(email.body).to include('What happens next?')
        expect(email.body).to include(
          "If you want to accept your offer of a place on a teacher training course, you must do so by #{winter_deadline}.",
        )
        expect(email.body).to include(
          "If you do not want to accept this offer, you can still apply to courses starting later in #{next_recruitment_cycle_year} and in #{next_recruitment_cycle_year + 1}.",
        )
        expect(email.body).to include('Sign in to your account to apply for courses')
        expect(email.body).to include(
          'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
        )
      end
    end

    context 'with many application choices' do
      let(:jan_choice) { create(:application_choice, :offer, course_option: jan_course_option, application_form:) }
      let(:jan_course_2) { create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
      let(:jan_course_option_2) { create(:course_option, course: jan_course_2) }
      let(:jan_choice_2) { create(:application_choice, :offer, application_form:, course_option: jan_course_option_2) }

      before do
        jan_choice
        jan_choice_2
      end

      it 'renders the content' do
        expect(email.subject).to eq("Accept your place on a teacher training course by #{winter_deadline}")
        expect(email.body).to include("Dear #{application_form.first_name}")
        expect(email.body).to include('You have been offered places on the following teacher training courses:')
        expect(email.body).to include("#{jan_choice.course.name_and_code} at #{jan_choice.provider.name}")
        expect(email.body).to include("#{jan_choice_2.course.name_and_code} at #{jan_choice_2.provider.name}")
        expect(email.body).not_to include("#{application_choice.course.name_and_code} at #{application_choice.provider.name}")
        expect(email.body).to include("If you want to accept an offer, you must do so by #{winter_deadline}.")
        expect(email.body).to include('Your other applications')
        expect(email.body).to include(
          "Your other applications for teacher training starting in January #{next_recruitment_cycle_year} have been automatically rejected.",
        )
        expect(email.body).to include(
          'This is because the provider did not respond before their deadline. If you have any questions about this, please contact the provider.',
        )
        expect(email.body).to include('What happens next?')
        expect(email.body).to include(
          "If you want to accept your offer of a place on a teacher training course, you must do so by #{winter_deadline}.",
        )
        expect(email.body).to include(
          "If you do not want to accept this offer, you can still apply to courses starting later in #{next_recruitment_cycle_year} and in #{next_recruitment_cycle_year + 1}.",
        )
        expect(email.body).to include('Sign in to your account to apply for courses')
        expect(email.body).to include(
          'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
        )
      end
    end
  end
end

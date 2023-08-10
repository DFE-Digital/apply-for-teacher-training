require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::SubmitApplicationForm, continuous_applications: true do
  subject(:submit_application_form) { described_class.new(attributes) }

  let(:attributes) { { application_choice: } }
  let(:application_form) { create(:application_form) }
  let(:application_choice) { create(:application_choice, application_form:) }

  context 'validations' do
    context 'when no answer is provider' do
      it 'adds error to submit answer' do
        expect(submit_application_form.valid?(:answer)).to be_falsey
        expect(submit_application_form.errors[:submit_answer]).to be_present
      end
    end

    context 'when your details are incomplete' do
      let(:application_form) { create(:application_form, :minimum_info) }

      it 'adds error to application choice' do
        expect(submit_application_form.valid?(:submission)).to be_falsey
        expect(submit_application_form.errors[:application_choice]).to include('You cannot submit this application until you’ve completed your details.')
      end
    end

    context 'when candidate can not apply outside of the cycle' do
      it 'adds error to application choice' do
        travel_temporarily_to(Time.zone.local(2023, 10, 4)) do
          expect(submit_application_form.valid?(:submission)).to be_falsey
          expect(submit_application_form.errors[:application_choice]).to include(
            'You cannot submit this application now. You will be able to submit it from 10 October 2023 at 9am.',
          )
        end
      end
    end

    context 'when application is already submitted' do
      let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }

      it 'adds error to application choice' do
        expect(submit_application_form.valid?(:submission)).to be_falsey
        expect(submit_application_form.errors[:application_choice]).to include(
          'You cannot submit this application because it is already submitted.',
        )
      end
    end

    context 'when course is not open for applications' do
      let(:course) do
        create(:course, :open_on_apply, name: 'Primary', code: '2XT2', applications_open_from: 2.days.from_now)
      end
      let(:course_option) { create(:course_option, course:) }
      let(:application_form) { create(:application_form, :completed) }
      let(:application_choice) do
        create(:application_choice, :unsubmitted, course_option:, application_form:)
      end

      it 'adds error to application choice' do
        travel_temporarily_to(Time.zone.local(2023, 10, 11)) do
          expect(submit_application_form.valid?(:submission)).to be_falsey
          expect(submit_application_form.errors[:application_choice]).to include(
            "You cannot submit this application now because the course has not opened. You will be able to submit it from #{course.applications_open_from.to_fs(:govuk_date)}.",
          )
        end
      end
    end

    context 'when course is full' do
      let(:course) do
        create(:course, :open_on_apply, name: 'Primary', code: '2XT2', exposed_in_find: false)
      end
      let(:course_option) { create(:course_option, course:, vacancy_status: 'no_vacancies') }
      let(:application_form) { create(:application_form, :completed) }
      let(:application_choice) do
        create(:application_choice, :unsubmitted, course_option:, application_form:)
      end

      it 'adds error to application choice' do
        submit_application_form.valid?(:submission)
        expect(submit_application_form.errors[:application_choice]).to include(
          'You cannot submit this application because there are no places left on the course.',
        )
        expect(submit_application_form.errors[:application_choice]).to include(
          'You need to either remove this application or change your course.',
        )
      end
    end

    context 'when not exposed in find' do
      let(:course) do
        create(:course, :open_on_apply, name: 'Primary', code: '2XT2', exposed_in_find: false)
      end
      let(:course_option) { create(:course_option, course:, site_still_valid: false) }
      let(:application_form) { create(:application_form, :completed) }
      let(:application_choice) do
        create(:application_choice, :unsubmitted, course_option:, application_form:)
      end

      it 'adds error to application choice' do
        submit_application_form.valid?(:submission)
        expect(submit_application_form.errors[:application_choice]).to include(
          'You cannot submit this application because it’s no longer available. You need to either remove it or change the course.',
        )
      end
    end

    context 'when site is invalid' do
      let(:course) do
        create(:course, :open_on_apply, name: 'Primary', code: '2XT2', applications_open_from: 2.days.from_now)
      end
      let(:course_option) { create(:course_option, course:, site_still_valid: false) }
      let(:application_form) { create(:application_form, :completed) }
      let(:application_choice) do
        create(:application_choice, :unsubmitted, course_option:, application_form:)
      end

      it 'adds error to application choice' do
        submit_application_form.valid?(:submission)
        expect(submit_application_form.errors[:application_choice]).to include(
          'You cannot submit this application because it’s no longer available. You need to either remove it or change the course.',
        )
        expect(submit_application_form.errors[:application_choice]).to include(
          "#{application_choice.current_provider.name} may be able to also recommend an alternative course.",
        )
      end
    end

    context 'when application is ready for submit' do
      let(:application_form) { create(:application_form, :completed, course_choices_completed: false) }
      let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

      it 'returns valid record' do
        submit_application_form.valid?(:submission)
        expect(submit_application_form.errors[:application_choice]).to be_empty
      end
    end
  end

  describe '#submit_now?' do
    context 'when the answer is yes' do
      let(:attributes) { { submit_answer: 'yes' } }

      it 'returns true' do
        expect(submit_application_form.submit_now?).to be_truthy
      end
    end

    context 'when the answer is no' do
      let(:attributes) { { submit_answer: 'no' } }

      it 'returns false' do
        expect(submit_application_form.submit_now?).to be_falsey
      end
    end
  end
end

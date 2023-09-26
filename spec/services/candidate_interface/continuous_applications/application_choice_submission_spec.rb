require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission, continuous_applications: false do
  subject(:application_choice_submission) do
    described_class.new(application_choice:)
  end

  let(:application_form) { create(:application_form) }
  let(:application_choice) { create(:application_choice, application_form:) }

  describe 'validations' do
    context 'when your details are incomplete' do
      let(:application_form) { create(:application_form, :minimum_info) }

      it 'adds errors to application choice' do
        expect(application_choice_submission).not_to be_valid
        expect(application_choice_submission.errors[:application_choice]).to include('You cannot submit this application until you’ve completed your details')
        expect(application_choice_submission.errors[:application_choice]).to include('To apply for a Primary course, you need a GCSE in science at grade 4 (C) or above, or equivalent')
        expect(application_choice_submission.errors[:application_choice]).to include('<a class="govuk-link" href="/candidate/application/gcse/science">Add your science GCSE grade (or equivalent) before submitting this application</a>')
      end

      context 'when science GCSE is not needed' do
        let(:course) { create(:course, level: 'secondary') }
        let(:course_option) { create(:course_option, course:) }
        let(:application_choice) { create(:application_choice, course_option:) }

        it 'does not add the science GCSE errors' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).not_to include('To apply for a Primary course, you need a GCSE in science at grade 4 (C) or above, or equivalent.')
          expect(application_choice_submission.errors[:application_choice]).not_to include('<a href="/candidate/application/gcse/science">Add your science GCSE grade (or equivalent) before submitting this application.</a>')
        end
      end
    end

    context 'when candidate can not apply outside of the cycle' do
      it 'adds error to application choice' do
        travel_temporarily_to(Time.zone.local(2023, 10, 4)) do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(
            'You cannot submit this application now. You will be able to submit it from 10 October 2023 at 9am.',
          )
        end
      end
    end

    context 'when application is already submitted' do
      let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }

      it 'adds error to application choice' do
        expect(application_choice_submission).not_to be_valid
        expect(application_choice_submission.errors[:application_choice]).to include(
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
          expect(application_choice_submission.valid?).to be_falsey
          expect(application_choice_submission.errors[:application_choice]).to include(
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
        application_choice_submission.valid?
        expect(application_choice_submission.errors[:application_choice]).to include(
          'You cannot submit this application because there are no places left on the course',
        )
        expect(application_choice_submission.errors[:application_choice]).to include(
          'You need to either remove this application or change your course',
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
        application_choice_submission.valid?
        expect(application_choice_submission.errors[:application_choice]).to include(
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
        application_choice_submission.valid?
        expect(application_choice_submission.errors[:application_choice]).to include(
          'You cannot submit this application because it’s no longer available. You need to either remove it or change the course.',
        )
        expect(application_choice_submission.errors[:application_choice]).to include(
          "#{application_choice.current_provider.name} may be able to also recommend an alternative course.",
        )
      end
    end

    context 'when the candidate has submitted the maximum amount of application choices' do
      before do
        application_form.application_choices << build_list(:application_choice, 4, status: :awaiting_provider_decision)
      end

      it 'adds error to application choice' do
        application_choice_submission.valid?
        expect(application_choice_submission.errors[:application_choice]).to include(
          'You cannot submit this application because you have already submitted the maximum number of applications.',
        )
      end
    end

    context 'when the candidate has reached the maximum number of unsuccessful choices' do
      before do
        application_form.application_choices << build_list(:application_choice, 20, status: :rejected)
      end

      it 'adds error to application choice' do
        application_choice_submission.valid?
        expect(application_choice_submission.errors[:application_choice]).to include(
          "You cannot submit this application because you have #{ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS} unsuccessful applications.",
        )
      end
    end

    context 'when application is ready for submit' do
      let(:application_form) { create(:application_form, :completed, course_choices_completed: false) }
      let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

      it 'returns valid record' do
        application_choice_submission.valid?
        expect(application_choice_submission.errors[:application_choice]).to be_empty
      end
    end
  end
end

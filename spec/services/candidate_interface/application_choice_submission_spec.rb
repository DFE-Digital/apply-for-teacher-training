require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoiceSubmission do
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  subject(:application_choice_submission) { described_class.new(application_choice:) }

  let(:routes) { Rails.application.routes.url_helpers }

  describe 'validations', time: mid_cycle do
    context 'incomplete postgraduate details validation', time: mid_cycle(2025) do
      let(:course) do
        create(
          :course,
          :open,
        )
      end
      let(:application_choice) do
        create(:application_choice, :unsubmitted, course_option: create(:course_option, course:), application_form:)
      end

      context 'when all postgraduate course details are complete' do
        let(:application_form) { create(:application_form, :completed, :with_degree) }

        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when applying to an undergraduate course' do
        let(:course) do
          create(
            :course,
            :open,
            :teacher_degree_apprenticeship,
          )
        end
        let(:application_form) do
          create(
            :application_form,
            :completed,
            application_qualifications: [],
            university_degree: false,
          )
        end

        it 'does not add an error to the application choice' do
          application_choice_submission.valid?

          expect(
            application_choice_submission.errors.of_kind?(:application_choice, :incomplete_postgraduate_course_details),
          ).to be false
        end
      end

      context 'when postgraduate course details are incomplete' do
        let(:application_form) do
          create(
            :application_form,
            :completed,
            university_degree: false,
            degrees_completed: true,
            recruitment_cycle_year: 2025,
          )
        end

        it 'adds an error to the application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice].first).to include(
            "To apply for this course, you need a bachelor’s degree or equivalent qualification.\n\n#{link_to_postgraduate_details_error_message} and complete the rest of your details. You can then submit your application.\n\nYour application will be saved as a draft while you finish adding your details.",
          )
        end
      end

      def link_to_postgraduate_details_error_message
        govuk_link_to(
          'Add your degree (or equivalent)',
          routes.candidate_interface_degree_university_degree_path,
        )
      end
    end

    context 'incomplete_undergraduate_course_details validation' do
      let(:course) do
        create(
          :course,
          :open,
          :teacher_degree_apprenticeship,
        )
      end
      let(:application_choice) do
        create(:application_choice, :unsubmitted, course_option: create(:course_option, course:), application_form:)
      end

      context 'when all undergraduate course details are complete' do
        let(:application_form) do
          create(:application_form, :completed, :with_a_levels)
        end

        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when undergraduate course details are incomplete' do
        let(:application_form) do
          create(
            :application_form,
            :completed,
            no_other_qualifications: true,
            application_qualifications: [],
          )
        end

        it 'adds an error to the application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice].first).to include(
            "To apply for this course, you need an A level or equivalent qualification.\n\n#{link_to_undergraduate_details_error_message} and complete the rest of your details. You can then submit your application.\n\nYour application will be saved as a draft while you finish adding your details.",
          )
        end
      end

      def link_to_undergraduate_details_error_message
        govuk_link_to(
          'Add an A level (or equivalent)',
          routes.candidate_interface_other_qualification_type_path,
        )
      end
    end

    context 'immigration_status validation' do
      let(:course) { create(:course, :with_course_options, :open, level: 'secondary') }
      let(:application_form) { create(:application_form, :completed, :with_degree) }
      let(:application_choice) { create(:application_choice, :unsubmitted, course:, application_form:) }
      let(:link_to_find) do
        govuk_link_to(
          'Find a course that has visa sponsorship',
          routes.find_url,
          target: '_blank',
          rel: 'nofollow',
        )
      end

      context 'when candidate is uk or irish national' do
        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when candidate is American without right to work but course is salary and sponsored' do
        let(:application_form) do
          create(
            :application_form,
            :completed,
            :with_degree,
            first_nationality: 'American',
            right_to_work_or_study: 'no',
            efl_completed: true,
          )
        end
        let(:course) do
          create(
            :course,
            :with_course_options,
            :open,
            funding_type: 'fee',
            can_sponsor_student_visa: true,
            level: 'secondary',
          )
        end

        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when candidate nationality is not British or Irish' do
        let(:application_form) do
          create(
            :application_form,
            :completed,
            first_nationality: 'American',
            right_to_work_or_study: 'no',
            efl_completed: true,
          )
        end

        it 'adds error to application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(
            t('activemodel.errors.models.candidate_interface/application_choice_submission.attributes.application_choice.immigration_status', link_to_find:),
          )
        end
      end

      context 'when candidate has no right to work but course does not sponsor visa' do
        let(:application_form) { create(:application_form, :completed, first_nationality: 'American', right_to_work_or_study: 'no', efl_completed: true) }
        let(:course) { create(:course, :with_course_options, :open, funding_type: 'fee', can_sponsor_student_visa: false, level: 'secondary') }

        it 'adds error to application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(
            t('activemodel.errors.models.candidate_interface/application_choice_submission.attributes.application_choice.immigration_status', link_to_find:),
          )
        end
      end
    end

    context 'applications_closed validation' do
      let(:course) { create(:course, :with_course_options, :open, level: 'secondary') }
      let(:application_form) { create(:application_form, :completed, :with_degree) }
      let(:application_choice) { create(:application_choice, :unsubmitted, course:, application_form:) }

      context 'when apply is open and course is open for applications' do
        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when apply is open but course not open for applications' do
        it 'adds error to application choice' do
          application_choice.course.update(applications_open_from: 1.day.from_now)

          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(
            "This course is not yet open to applications. You will be able to submit your application on #{1.day.from_now.to_fs(:govuk_date)}.",
          )
        end
      end

      context 'when apply is closed and course open for applications same day' do
        it 'adds error to application choice', time: after_find_opens do
          apply_opens_date = RecruitmentCycleTimetable.current_timetable.apply_opens_at.to_fs(:govuk_date)
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(
            "This course is not yet open to applications. You will be able to submit your application on #{apply_opens_date}.",
          )
        end
      end

      context 'when apply is open and course open for applications next day' do
        let(:applications_open_from) { 1.day.from_now }
        let(:course) { create(:course, :with_course_options, level: 'secondary', applications_open_from:) }

        it 'adds error to application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(
            "This course is not yet open to applications. You will be able to submit your application on #{course.applications_open_from.to_fs(:govuk_date)}.",
          )
        end
      end
    end

    context 'course_unavailable validation' do
      let(:course) { build(:course, :open, course_options: []) }
      let(:course_option) { create(:course_option, course: course) }
      let(:application_form) { create(:application_form, :completed, :with_degree) }
      let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

      context 'all validations pass' do
        let(:course) { build(:course, :open, :with_course_options) }

        it 'adds no errors to application choice submission' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'course is full' do
        let(:course_option) { create(:course_option, :no_vacancies, course: course) }
        let(:application_choice) { create(:application_choice, course_option: course_option, application_form:) }

        it 'adds error to application choice submission' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(course_unavailable_error_message(application_choice))
        end
      end

      context 'course not exposed in find' do
        let(:course) { build(:course, :open, exposed_in_find: false, course_options: []) }
        let(:application_form) { create(:application_form, :minimum_info) }
        let(:application_choice) { create(:application_choice, course_option: course_option, application_form:) }

        it 'adds error to application choice submission' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(course_unavailable_error_message(application_choice))
        end
      end

      context 'course site not still valid' do
        let(:course_option) { create(:course_option, site_still_valid: false, course: course) }
        let(:application_form) { create(:application_form, :minimum_info) }
        let(:application_choice) { create(:application_choice, course_option: course_option, application_form:) }

        it 'adds error to application choice submission' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(course_unavailable_error_message(application_choice))
        end
      end

      def course_unavailable_error_message(application_choice)
        <<~MSG.chomp
          You cannot submit this application because the course is no longer available.

          #{govuk_link_to('Remove this application', Rails.application.routes.url_helpers.candidate_interface_course_choices_confirm_destroy_course_choice_path(application_choice.id))} and search for other courses.
        MSG
      end
    end

    context 'incomplete_primary_course_details validation' do
      let(:course_option) { create(:course_option, course:) }
      let(:course) { create(:course, :open, :primary, :with_course_options) }
      let(:application_form) { create(:application_form, :completed, :with_degree) }
      let(:application_choice) { create(:application_choice, :unsubmitted, application_form:, course:) }

      context 'when all sections are completed' do
        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'primary course with only science gcse section incomplete' do
        let(:course_option) { create(:course_option, course:) }
        let(:application_form) { create(:application_form, :completed, science_gcse_completed: false) }
        let(:application_choice) { create(:application_choice, :unsubmitted, course_option:, application_form:) }
        let(:course) { create(:course, :open, :primary) }

        it 'adds error to application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(link_to_gcse_error_message)
        end
      end

      context 'when secondary course choice with only science gcse section incomplete' do
        let(:course) { create(:course, :open, :secondary) }
        let(:course_option) { create(:course_option, course:) }
        let(:application_form) { create(:application_form, :completed, :with_degree, science_gcse_completed: false) }
        let(:application_choice) { create(:application_choice, :unsubmitted, course_option:, application_form:) }

        it 'is valid' do
          application_choice_submission.valid?

          expect(application_choice_submission.errors).to be_empty
        end
      end

      context 'primary courses with science gcse section incomplete and other details incomplete' do
        let(:application_form) { create(:application_form, :completed, degrees_completed: false, science_gcse_completed: false) }
        let(:application_choice) { create(:application_choice, :unsubmitted, course_option:, application_form:) }

        it 'adds error to application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(link_to_details_error_message)
        end
      end

      context 'when secondary courses with science gcse section incomplete and other details incomplete' do
        let(:course) { create(:course, :open, :secondary) }
        let(:course_option) { create(:course_option, course:) }
        let(:application_form) { create(:application_form, :completed, degrees_completed: false, science_gcse_completed: false) }
        let(:application_choice) { create(:application_choice, :unsubmitted, course_option:, application_form:) }

        it 'does not add an error to incomplete science GCSE' do
          application_choice_submission.valid?

          expect(application_choice_submission.errors.map(&:type)).to eq([:incomplete_details])
        end
      end

      def link_to_details_error_message
        link_to_details = govuk_link_to('Add your science GCSE grade (or equivalent)', Rails.application.routes.url_helpers.candidate_interface_details_path)
        t('activemodel.errors.models.candidate_interface/application_choice_submission.attributes.application_choice.incomplete_details_including_primary_course_details', link_to_details:)
      end

      def link_to_gcse_error_message
        link_to_science = govuk_link_to('Add your science GCSE grade (or equivalent)', Rails.application.routes.url_helpers.candidate_interface_gcse_details_new_type_path('science'))

        t('activemodel.errors.models.candidate_interface/application_choice_submission.attributes.application_choice.incomplete_primary_course_details', link_to_science:)
      end
    end

    context 'incomplete_details validation' do
      let(:application_form) { create(:application_form, :completed, :with_degree) }
      let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

      context 'valid' do
        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'sections incomplete' do
        let(:application_form) { create(:application_form, :completed, degrees_completed: false) }
        let(:application_choice) { create(:application_choice, application_form:) }

        it 'adds error to application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(incomplete_details_error_message)
        end
      end

      def incomplete_details_error_message
        <<~MSG.chomp
          You cannot submit this application until you #{govuk_link_to('complete your details', Rails.application.routes.url_helpers.candidate_interface_details_path)}.

          Your application will be saved as a draft while you finish adding your details.
        MSG
      end
    end

    context 'add more course choices validation' do
      context 'when candidate can submit further applications' do
        let(:application_form) { create(:completed_application_form, :with_degree, submitted_application_choices_count: 3) }
        let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

        it 'is valid' do
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when candidate has conditions not met and can submit further applications' do
        let(:application_form) { create(:completed_application_form, :with_degree) }
        let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

        it 'is valid' do
          create_list(:application_choice, 4, :conditions_not_met, application_form:)
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when candidate can not submit further applications' do
        let(:application_form) { create(:completed_application_form, :with_degree, submitted_application_choices_count: 4) }
        let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

        it 'adds error to application choice' do
          expect(application_choice_submission).not_to be_valid
          expect(application_choice_submission.errors[:application_choice]).to include(
            'You cannot submit this application because you have already submitted the maximum number of applications',
          )
        end
      end

      context 'when candidate does not reach the maximum unsuccessful choices' do
        let(:application_form) { create(:completed_application_form, :with_degree, submitted_application_choices_count: 3) }
        let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

        it 'is valid' do
          application_form.application_choices << build_list(
            :application_choice,
            ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS - 1,
            :rejected,
          )
          expect(application_choice_submission).to be_valid
        end
      end

      context 'when candidate reaches the maximum unsuccessful choices' do
        let(:application_form) { create(:completed_application_form) }
        let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

        it 'adds error to application choice' do
          application_form.application_choices << build_list(
            :application_choice,
            ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS,
            :rejected,
          )
          expect(application_choice_submission).not_to be_valid

          expect(application_choice_submission.errors[:application_choice]).to include(
            "You cannot submit this application because you have #{ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS} unsuccessful applications",
          )
        end
      end
    end
  end
end

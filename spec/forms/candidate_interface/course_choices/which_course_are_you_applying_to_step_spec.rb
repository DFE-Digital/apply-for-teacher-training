require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::WhichCourseAreYouApplyingToStep do
  subject(:which_course_are_you_applying_to_step) { described_class.new(provider_id:, course_id:, wizard:) }

  let(:candidate) { create(:candidate) }
  let(:provider) { create(:provider, selectable_school: true) }
  let(:course) do
    create(
      :course,
      :open,
      :with_both_study_modes,
      provider:,
      name: 'Software Engineering',
    )
  end
  let(:course_option) { create(:course_option, :full_time, course:) }
  let(:current_application) { create(:application_form, :completed, candidate:, submitted_at: nil) }
  let(:application_choice) { nil }
  let(:edit) { false }
  let(:step_params) { ActionController::Parameters.new({ which_course_are_you_applying_to: { course_id:, provider_id: } }) }
  let(:wizard) do
    CandidateInterface::CourseChoices::CourseSelectionWizard.new(
      current_step: :which_course_are_you_applying_to,
      step_params:,
      current_application:,
      edit:,
      application_choice:,
    )
  end

  let(:provider_id) { nil }
  let(:course_id) { nil }

  describe '.route_name' do
    subject { which_course_are_you_applying_to_step.class.route_name }

    it { is_expected.to eq('candidate_interface_course_choices_which_course_are_you_applying_to') }
  end

  describe 'validations' do
    it 'errors on course id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:course_id)
    end

    it 'errors on provider id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:provider_id)
    end

    context 'validates uniqueness of course_choice' do
      let(:provider_id) { provider.id }
      let(:course_id) { course.id }

      context 'when choice exists on the application form' do
        before do
          create(:application_choice, :inactive, course_option:, application_form: current_application)
        end

        it 'validates false and returns the correct error message' do
          expect(wizard.current_step.valid?(:course_choice)).to be false
          expect(wizard.current_step.errors.added?(:base, :duplicate_application_selection)).to be true
          expect(wizard.current_step.errors.added?(:base, :reached_reapplication_limit)).to be false
        end
      end

      context 'when course does not exist on application form' do
        it 'validates true' do
          expect(wizard.current_step.valid?(:course_choice)).to be true
        end
      end
    end

    context 'raw data is blank' do
      let(:step_params) do
        ActionController::Parameters.new(
          {
            which_course_are_you_applying_to: {
              course_id: course.id, provider_id: provider.id, course_id_raw: ''
            },
          },
        )
      end

      it 'is invalid' do
        expect(wizard.current_step.valid?).to be false
        expect(wizard.current_step.errors[:course_id]).to eq ['Select a course']
      end
    end

    context 'when raw data is a mismatch' do
      let(:step_params) do
        ActionController::Parameters.new(
          {
            which_course_are_you_applying_to: {
              course_id: course.id, provider_id: provider.id, course_id_raw: 'something else'
            },
          },
        )
      end

      it 'is invalid' do
        expect(wizard.current_step.valid?).to be false
        expect(wizard.current_step.errors[:course_id]).to eq ['Select a course']
      end
    end
  end

  context 'validates reapplication of course_choice' do
    let(:provider_id) { provider.id }
    let(:course_id) { course.id }

    context 'with one rejected choice on the application form' do
      before do
        create(:application_choice, :rejected, course_option:, application_form: current_application)
      end

      it 'validates true' do
        expect(wizard.current_step.valid?(:course_choice)).to be true
      end
    end

    context 'with two rejected choices on the application form' do
      before do
        create_list(:application_choice, 2, :rejected,
                    course_option:,
                    application_form: current_application)
      end

      it 'validates false and returns the correct error message' do
        expect(wizard.current_step.valid?(:course_choice)).to be false
        expect(wizard.current_step.errors.added?(:base, :reached_reapplication_limit)).to be true
        expect(wizard.current_step.errors.added?(:base, :duplicate_application_selection)).to be false
      end
    end

    context 'with two rejected choices from previous cycle on the application form' do
      before do
        create_list(:application_choice, 2, :rejected,
                    course_option:,
                    application_form: current_application,
                    current_recruitment_cycle_year: previous_year)
      end

      it 'validates true' do
        expect(wizard.current_step.valid?(:course_choice)).to be true
      end
    end
  end

  describe '#next_step' do
    let(:provider) { create(:provider, selectable_school: true) }
    let(:course) do
      create(
        :course,
        :open,
        :with_both_study_modes,
        provider:,
        name: 'Software Engineering',
      )
    end
    let(:provider_id) { provider.id }
    let(:course_id) { course.id }
    let(:application_choice) { nil }

    context 'when course has multiple study modes' do
      before do
        create(
          :course_option,
          course:,
          study_mode: :part_time,
        )
        create(
          :course_option,
          course:,
          study_mode: :part_time,
        )
        create(
          :course_option,
          course:,
          study_mode: :full_time,
        )
      end

      it 'returns :course_study_mode' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_study_mode)
      end
    end

    context 'when course has multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_site' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_site)
      end
    end

    context 'when course has multiple sites and provider school is not selectable', time: mid_cycle(2025) do
      let(:provider) { create(:provider, selectable_school: false) }

      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_review' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_review)
      end
    end

    context 'when course has no course availability' do
      it 'returns :full_course_selection' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:full_course_selection)
      end
    end

    context 'when course has single site and single study mode' do
      before do
        create(:course_option, course:)
      end

      it 'returns :course_review' do
        expect(which_course_are_you_applying_to_step.next_step).to be(:course_review)
      end
    end

    context 'when choice exists on application form' do
      let(:application_choice) { create(:application_choice, :inactive, course_option:, application_form: current_application) }

      it 'returns :duplicate_course_selection' do
        expect(wizard.current_step.next_step).to be(:duplicate_course_selection)
      end
    end

    context 'when editing the course choice and choosing the same course' do
      let(:edit) { true }
      let(:application_choice) { create(:application_choice, course_option:, application_form: current_application) }
      let(:provider_id) { application_choice.course_option.course.provider.id }
      let(:course_id) { application_choice.course_option.course.id }
      let(:step_params) { ActionController::Parameters.new({ which_course_are_you_applying_to: { course_id:, provider_id: } }) }

      it 'returns :course_review' do
        expect(wizard.current_step.next_step).to be(:course_review)
      end
    end

    context 'when editing the second course choice and choosing the first course choice' do
      let(:edit) { true }
      let(:first_choice) { create(:application_choice, course_option: create(:course_option, course: create(:course, provider:)), application_form: current_application) }
      let(:second_choice) { create(:application_choice, course_option: create(:course_option, course: create(:course, provider:)), application_form: current_application) }
      let(:provider_id) { first_choice.course_option.course.provider.id }
      let(:course_id) { first_choice.course_option.course.id }
      let(:step_params) { ActionController::Parameters.new({ which_course_are_you_applying_to: { course_id:, provider_id: } }) }
      let(:application_choice) { second_choice }

      it 'returns :duplicate_course_selection' do
        expect(wizard.current_step.next_step).to be(:duplicate_course_selection)
      end
    end

    context 'when course choice has no availability' do
      let(:application_choice) { create(:application_choice) }

      it 'returns :duplicate_course_selection' do
        expect(wizard.current_step.next_step).to be(:full_course_selection)
      end
    end
  end
end

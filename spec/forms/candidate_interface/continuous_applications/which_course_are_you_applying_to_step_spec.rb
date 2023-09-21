require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::WhichCourseAreYouApplyingToStep do
  subject(:which_course_are_you_applying_to_step) { described_class.new(provider_id:, course_id:, wizard:) }

  let(:candidate) { create(:candidate) }
  let(:provider) { create(:provider) }
  let(:course) do
    create(
      :course,
      :with_both_study_modes,
      :open_on_apply,
      provider:,
      name: 'Software Engineering',
    )
  end
  let(:course_option) { create(:course_option, :open_on_apply, :full_time, course:) }
  let(:current_application) { create(:application_form, :completed, candidate:, submitted_at: nil) }
  let(:application_choice) { nil }
  let(:edit) { false }
  let(:wizard) do
    CandidateInterface::ContinuousApplications::CourseSelectionWizard.new(
      current_step: :which_course_are_you_applying_to,
      step_params: ActionController::Parameters.new({ which_course_are_you_applying_to: { course_id:, provider_id: } }),
      current_application:,
      edit:,
      application_choice:,
    )
  end

  let(:provider_id) { nil }
  let(:course_id) { nil }

  describe 'validations' do
    it 'errors on course id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:course_id)
    end

    it 'errors on provider id' do
      expect(which_course_are_you_applying_to_step).to validate_presence_of(:provider_id)
    end

    context 'validates uniqueness of course_choice', :continuous_applications do
      let(:provider_id) { provider.id }
      let(:course_id) { course.id }

      context 'when choice exists on the application form' do
        let(:application_choice) { create(:application_choice, :inactive, course_option:, application_form: current_application) }

        it 'validates false' do
          expect(wizard.current_step.valid?(:course_choice)).to be false
        end
      end

      context 'when course does not exist on application form' do
        let(:application_choice) { nil }

        it 'validates true' do
          expect(wizard.current_step.valid?(:course_choice)).to be true
        end
      end
    end
  end

  describe '#next_step' do
    let(:provider) { create(:provider) }
    let(:course) do
      create(
        :course,
        :with_both_study_modes,
        :open_on_apply,
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

    context 'when course has single site and single study mode' do
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

    context 'when editing the course choice and choosing duplicate course' do
      let(:edit) { true }
      let(:application_choice) { create(:application_choice, :inactive, course_option:, application_form: current_application) }

      it 'returns :course_review' do
        expect(wizard.current_step.next_step).to be(:course_review)
      end
    end
  end
end

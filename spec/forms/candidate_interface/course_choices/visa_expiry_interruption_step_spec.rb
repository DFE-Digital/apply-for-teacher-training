require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::VisaExpiryInterruptionStep do
  include Rails.application.routes.url_helpers

  subject(:visa_expiry_interruption_step) do
    described_class.new(application_choice_id:, wizard:)
  end

  let(:application_choice_id) { nil }
  let(:wizard) do
    CandidateInterface::CourseChoices::CourseSelectionWizard.new(
      current_step: :visa_expiry_interruption,
      step_params: nil,
      application_choice:,
    )
  end
  let(:application_choice) { build(:application_choice) }

  describe '.route_name' do
    subject { visa_expiry_interruption_step.class.route_name }

    it { is_expected.to eq('candidate_interface_course_choices_visa_expiry_interruption') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:application_choice_id) }
  end

  describe '#next_step' do
    it 'returns :visa_explanation' do
      expect(visa_expiry_interruption_step.next_step).to be(:visa_explanation)
    end
  end

  describe '#next_step_path_arguments' do
    it 'returns the arguments' do
      expect(visa_expiry_interruption_step.next_step_path_arguments).to eq({ application_choice_id: })
    end
  end

  describe '#previous_step' do
    let(:application_choice) { create(:application_choice, course:) }
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

    it 'returns :which_course_are_you_applying_to' do
      expect(visa_expiry_interruption_step.previous_step).to be(:which_course_are_you_applying_to)
    end

    context 'with multiple study modes' do
      before do
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
        expect(visa_expiry_interruption_step.previous_step).to be(:course_study_mode)
      end
    end

    context 'with multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_site' do
        expect(visa_expiry_interruption_step.previous_step).to be(:course_site)
      end
    end
  end

  describe '#previous_step_path' do
    let(:application_choice) { create(:application_choice, course:) }
    let(:application_choice_id) { application_choice.id }
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

    it 'returns :which_course_are_you_applying_to' do
      expect(visa_expiry_interruption_step.previous_step_path(nil)).to eq(
        candidate_interface_edit_course_choices_which_course_are_you_applying_to_path(
          application_choice,
        ),
      )
    end

    context 'with multiple study modes' do
      before do
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
        expect(visa_expiry_interruption_step.previous_step_path(nil)).to eq(
          candidate_interface_edit_course_choices_course_study_mode_path(
            application_choice.id,
            course.id,
          ),
        )
      end
    end

    context 'with multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_site' do
        expect(visa_expiry_interruption_step.previous_step_path(nil)).to eq(
          candidate_interface_edit_course_choices_course_site_path(
            application_choice.id,
            course.id,
            application_choice.current_course_option.study_mode,
          ),
        )
      end
    end
  end
end

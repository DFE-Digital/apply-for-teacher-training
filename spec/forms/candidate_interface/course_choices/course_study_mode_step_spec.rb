require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::CourseStudyModeStep do
  subject(:course_study_mode_step) { described_class.new(provider_id:, course_id:, wizard:) }

  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:wizard) do
    CandidateInterface::CourseChoices::CourseSelectionWizard.new(
      current_step: :course_site,
      step_params: nil,
      application_choice:,
    )
  end
  let(:application_choice) { build(:application_choice) }

  before do
    wizard.store.application_choice = application_choice
  end

  describe '.route_name' do
    subject { course_study_mode_step.class.route_name }

    it { is_expected.to eq('candidate_interface_course_choices_course_study_mode') }
  end

  describe 'validations' do
    it 'errors on course id' do
      expect(course_study_mode_step).to validate_presence_of(:study_mode)
    end
  end

  describe '#next_step' do
    let(:provider) { create(:provider, selectable_school: true) }
    let(:course) do
      create(
        :course,
        :with_both_study_modes,
        provider:,
        name: 'Software Engineering',
      )
    end
    let(:provider_id) { provider.id }
    let(:course_id) { course.id }

    context 'when course has multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_site' do
        expect(course_study_mode_step.next_step).to be(:course_site)
      end
    end

    context 'when course has multiple sites and provider school is not selectable', time: mid_cycle(2025) do
      let(:provider) { create(:provider, selectable_school: false) }

      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'returns :course_review' do
        expect(course_study_mode_step.next_step).to be(:course_review)
      end
    end

    context 'when course has single site' do
      let(:site) { create(:site, provider:) }

      before do
        create(:course_option, :full_time, course:, site:)
        create(:course_option, :part_time, course:, site:)
      end

      it 'returns :course_review' do
        expect(course_study_mode_step.next_step).to be(:course_review)
      end
    end

    context 'when visa expiry flag is on and visa expires soon' do
      before do
        FeatureFlag.activate('2027_visa_expiry')
      end

      let(:application_form) { create(:application_form, visa_expired_at: 1.day.from_now) }
      let(:application_choice) { create(:application_choice, application_form:) }

      it 'returns :visa_expiry_interruption' do
        expect(course_study_mode_step.next_step).to be(:visa_expiry_interruption)
      end
    end

    context 'when visa expiry flag is on and visa will not expire soon' do
      before do
        FeatureFlag.activate('2027_visa_expiry')
      end

      let(:application_form) { create(:application_form, visa_expired_at: 2.years.from_now) }
      let(:application_choice) { create(:application_choice, application_form:) }

      it 'returns :course_review' do
        expect(course_study_mode_step.next_step).to be(:course_review)
      end
    end
  end
end

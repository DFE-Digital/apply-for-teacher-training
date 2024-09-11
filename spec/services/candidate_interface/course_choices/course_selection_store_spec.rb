require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::CourseSelectionStore do
  subject(:store) { described_class.new(wizard) }

  let(:current_application) { create(:application_form) }
  let(:application_choice) { current_application.application_choices.last }
  let(:wizard) do
    CandidateInterface::CourseChoices::CourseSelectionWizard.new(
      current_step:,
      step_params: ActionController::Parameters.new({ current_step => step_params }),
      current_application:,
    )
  end

  describe '#update' do
    let(:wizard) do
      CandidateInterface::CourseChoices::CourseSelectionWizard.new(
        current_step:,
        step_params: ActionController::Parameters.new({ current_step => step_params }),
        current_application:,
        application_choice:,
      )
    end
    let(:application_form) { current_application }
    let(:application_choice) { create(:application_choice, :unsubmitted, course:, application_form:) }
    let(:provider) { create(:provider) }
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
    let(:application_choice_id) { application_choice.id }

    context 'when course has multiple study modes' do
      let(:site) { create(:site, provider:) }
      let!(:part_time) do
        create(
          :course_option,
          :part_time,
          course:,
          site:,
        )
      end
      let!(:full_time) do
        create(
          :course_option,
          :full_time,
          course:,
          site:,
        )
      end
      let(:current_step) do
        :course_study_mode
      end
      let(:step_params) do
        { application_choice_id:, provider_id:, course_id:, study_mode: 'part_time' }
      end

      it 'uses the study mode parameter' do
        store.update
        expect(application_choice.course_option).to eq(part_time)
      end
    end

    context 'when course has multiple sites' do
      let!(:first_course_option) do
        create(:course_option, site: create(:site, provider:), course:)
      end
      let!(:second_course_option) do
        create(:course_option, site: create(:site, provider:), course:)
      end
      let(:current_step) do
        :course_site
      end
      let(:step_params) do
        { application_choice:, provider_id:, course_id:, course_option_id: first_course_option.id }
      end

      it 'uses the course option' do
        store.update
        expect(application_choice.course_option).to eq(first_course_option)
      end
    end

    context 'when course has single site and single study mode' do
      let(:current_step) do
        :which_course_are_you_applying_to
      end
      let(:step_params) do
        { provider_id:, course_id: }
      end
      let!(:course_option) do
        create(:course_option, course:)
      end

      it 'uses the only course option' do
        store.update
        expect(application_choice.course_option).to eq(course_option)
      end
    end
  end

  describe '#save' do
    let(:provider) { create(:provider) }
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

    context 'when course has multiple study modes' do
      let(:site) { create(:site, provider:) }
      let!(:part_time) do
        create(
          :course_option,
          :part_time,
          course:,
          site:,
        )
      end
      let!(:full_time) do
        create(
          :course_option,
          :full_time,
          course:,
          site:,
        )
      end
      let(:current_step) do
        :course_study_mode
      end
      let(:step_params) do
        { provider_id:, course_id:, study_mode: 'part_time' }
      end

      it 'uses the study mode parameter' do
        expect { store.save }.to change { current_application.application_choices.size }.from(0).to(1)
        expect(application_choice.course_option).to eq(part_time)
      end
    end

    context 'when course has multiple sites' do
      let!(:first_course_option) do
        create(:course_option, site: create(:site, provider:), course:)
      end
      let!(:second_course_option) do
        create(:course_option, site: create(:site, provider:), course:)
      end
      let(:current_step) do
        :course_site
      end
      let(:step_params) do
        { provider_id:, course_id:, course_option_id: first_course_option.id }
      end

      it 'uses the course option' do
        expect { store.save }.to change { current_application.application_choices.size }.from(0).to(1)
        expect(application_choice.course_option).to eq(first_course_option)
      end
    end

    context 'when course has single site and single study mode' do
      let(:current_step) do
        :which_course_are_you_applying_to
      end
      let(:step_params) do
        { provider_id:, course_id: }
      end
      let!(:course_option) do
        create(:course_option, course:)
      end

      it 'uses the only course option' do
        expect { store.save }.to change { current_application.application_choices.size }.from(0).to(1)
        expect(application_choice.course_option).to eq(course_option)
      end
    end
  end
end

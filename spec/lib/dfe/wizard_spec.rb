require 'rails_helper'

module TestWizard
  class TestDoYouKnowWhichCourse < DfE::WizardStep
    attr_accessor :answer
    validates :answer, presence: true

    def self.permitted_params
      [:answer]
    end

    def previous_step
      :first_step
    end

    def next_step
      if answer == 'yes'
        :test_provider_selection
      else
        :test_go_to_find
      end
    end
  end

  class TestProviderSelection < DfE::WizardStep
    attr_accessor :provider_id

    def previous_step
      :test_do_you_know_which_course
    end

    def next_step
      :test_course_name_selection
    end

    def next_step_path_arguments
      { provider_id: }
    end
  end

  class TestGoToFindStep < DfE::WizardStep
    def next_step; end
  end

  class TestCourseNameSelection < DfE::WizardStep
  end

  class TestCourseStudyModeSelection < DfE::WizardStep
  end

  class TestCourseSiteSelection < DfE::WizardStep
  end

  class TestReview < DfE::WizardStep
  end

  class MyAwesomeStoreService
    attr_reader :wizard

    def initialize(wizard)
      @wizard = wizard
    end

    def save
      :save_from_store_service
    end
  end

  class MyAwesomeCourseSelectionWizard < DfE::Wizard
    steps do
      [
        {
          test_do_you_know_which_course: TestDoYouKnowWhichCourse,
          test_go_to_find: TestGoToFindStep,
          test_provider_selection: TestProviderSelection,
          test_course_name_selection: TestCourseNameSelection,
          test_course_study_mode_selection: TestCourseStudyModeSelection,
          test_course_site_selection: TestCourseSiteSelection,
          test_review: TestReview,
        },
      ]
    end

    store MyAwesomeStoreService

    def logger
      Rails.logger if Rails.env.test?
    end
  end

  class TestAnotherWizardFirstStep < DfE::WizardStep
    def next_step
      :test_another_wizard_second
    end
  end

  class TestAnotherWizardSecondStep < DfE::WizardStep
  end

  class AnotherWizard < DfE::Wizard
    steps do
      [
        {
          test_another_wizard_first: TestAnotherWizardFirstStep,
          test_another_wizard_second: TestAnotherWizardSecondStep,
        },
      ]
    end

    def logger
      Rails.logger if Rails.env.development?
    end
  end
end

RSpec.describe DfE::Wizard do
  subject(:wizard) { TestWizard::MyAwesomeCourseSelectionWizard.new(current_step:, step_params:) }

  let(:current_step) { nil }
  let(:step_params) { {} }
  let(:my_awesome_course_selection_wizard_steps) do
    [
      {
        test_do_you_know_which_course: TestWizard::TestDoYouKnowWhichCourse,
        test_go_to_find: TestWizard::TestGoToFindStep,
        test_provider_selection: TestWizard::TestProviderSelection,
        test_course_name_selection: TestWizard::TestCourseNameSelection,
        test_course_study_mode_selection: TestWizard::TestCourseStudyModeSelection,
        test_course_site_selection: TestWizard::TestCourseSiteSelection,
        test_review: TestWizard::TestReview,
      },
    ]
  end

  describe '.steps' do
    it 'returns the steps declared in the block' do
      expect(
        TestWizard::MyAwesomeCourseSelectionWizard.steps,
      ).to eq(my_awesome_course_selection_wizard_steps)
    end
  end

  describe '#steps' do
    it 'pass the steps to the instance' do
      expect(wizard.steps).to eq(my_awesome_course_selection_wizard_steps)
    end
  end

  describe '#current_step' do
    context 'when there is no current step' do
      let(:current_step) { nil }

      it 'returns nil' do
        expect(wizard.current_step).to be_nil
      end
    end

    context 'when there is current step' do
      let(:current_step) { :test_go_to_find }

      it 'returns the instance of the current step' do
        expect(wizard.current_step).to be_instance_of(TestWizard::TestGoToFindStep)
      end
    end

    context 'when not to log' do
      subject(:wizard) { TestWizard::AnotherWizard.new(current_step: :test_another_wizard_first) }

      it 'do not log' do
        allow(Rails.logger).to receive(:info)
        wizard.current_step
        expect(Rails.logger).not_to have_received(:info)
      end
    end

    context 'when log' do
      let(:current_step) { :test_go_to_find }

      it 'do log' do
        allow(Rails.logger).to receive(:info)
        wizard.current_step
        expect(Rails.logger).to have_received(:info)
      end
    end
  end

  describe '#current_step_name' do
    context 'when there is no current step' do
      let(:current_step) { nil }

      it 'returns nil' do
        expect(wizard.current_step_name).to be_nil
      end
    end

    context 'when there is current step' do
      let(:current_step) { :test_go_to_find }

      it 'returns the instance of the current step' do
        expect(wizard.current_step_name).to be(:test_go_to_find)
      end
    end
  end

  describe '#step_params' do
    let(:current_step) { :test_do_you_know_which_course }
    let(:step_params) do
      { test_do_you_know_which_course: { answer: 'yes' } }
    end

    it 'assigns attributes to the current step' do
      expect(wizard.current_step.answer).to eq('yes')
    end
  end

  describe '#next_step' do
    let(:current_step) { :test_do_you_know_which_course }

    context 'when answer go to one page' do
      let(:step_params) do
        { test_do_you_know_which_course: { answer: 'yes' } }
      end

      it 'assigns attributes to the current step' do
        expect(wizard.next_step).to be(:test_provider_selection)
      end
    end

    context 'when answer go to another page' do
      let(:step_params) do
        { test_do_you_know_which_course: { answer: 'no' } }
      end

      it 'assigns attributes to the current step' do
        expect(wizard.next_step).to be(:test_go_to_find)
      end
    end
  end

  describe '#valid_step?' do
    let(:current_step) { :test_do_you_know_which_course }

    context 'when valid step' do
      let(:step_params) { { current_step => { answer: 'yes' } } }

      it 'returns true' do
        expect(wizard).to be_valid_step
      end

      it 'no error messages' do
        expect(wizard.current_step.errors).to be_blank
      end
    end

    context 'when invalid step' do
      let(:step_params) { {} }

      it 'returns false' do
        expect(wizard).to be_invalid_step
      end

      it 'adds error messages' do
        wizard.valid_step?
        expect(wizard.current_step.errors[:answer]).to eq(["can't be blank"])
      end
    end
  end

  describe '#permitted_params' do
    let(:current_step) { :test_do_you_know_which_course }

    it 'returns permitted params for current step' do
      expect(wizard.permitted_params).to eq([:answer])
    end
  end

  describe '#previous_step_path' do
    let(:current_step) { :test_do_you_know_which_course }

    context 'when first page' do
      let(:current_step) { :test_do_you_know_which_course }

      it 'returns the fallback' do
        expect(wizard.previous_step_path(fallback: '/fallback')).to eq('/fallback')
      end
    end

    context 'when any other page' do
      let(:current_step) { :test_provider_selection }

      before do
        # The named route is dynamic by form so we don't have the named route
        # for this spec.
        #
        without_partial_double_verification do
          allow(wizard.url_helpers).to receive(:test_wizard_test_do_you_know_which_course_path).and_return('/do-you-know-which-course')
        end
      end

      it 'returns the previous step' do
        expect(wizard.previous_step_path).to eq('/do-you-know-which-course')
      end
    end
  end

  describe '#next_step_path' do
    let(:current_step) { :test_do_you_know_which_course }

    context 'when next page does not exist' do
      let(:current_step) { :test_go_to_find }

      it 'raises missing step error' do
        expect {
          wizard.next_step_path
        }.to raise_error(DfE::Wizard::MissingStepError, 'Next step for TestGoToFind missing.')
      end
    end

    context 'when logger can log' do
      before do
        # The named route is dynamic by form so we don't have the named route
        # for this spec.
        #
        without_partial_double_verification do
          allow(wizard.url_helpers).to receive(:test_wizard_test_go_to_find_path).and_return('/go-to-find')
        end
      end

      it 'do log if conditions are met' do
        allow(Rails.logger).to receive(:info)
        wizard.next_step_path
        expect(Rails.logger).to have_received(:info).at_least(:once)
      end
    end

    context 'when logger can not log' do
      subject(:wizard) { TestWizard::AnotherWizard.new(current_step: :test_another_wizard_first) }

      before do
        # The named route is dynamic by form so we don't have the named route
        # for this spec.
        #
        without_partial_double_verification do
          allow(wizard.url_helpers).to receive(:test_wizard_test_another_wizard_second_path).and_return('/second-path')
        end
      end

      it 'do not log' do
        allow(Rails.logger).to receive(:info)
        wizard.next_step_path
        expect(Rails.logger).not_to have_received(:info)
      end
    end

    context 'when going to one branch' do
      let(:step_params) { { test_do_you_know_which_course: { answer: 'yes' } } }

      before do
        # The named route is dynamic by form so we don't have the named route
        # for this spec.
        #
        without_partial_double_verification do
          allow(wizard.url_helpers).to receive(:test_wizard_test_provider_selection_path).and_return('/provider-selection')
        end
      end

      it 'returns the named routes for the next step' do
        expect(wizard.next_step_path).to eq('/provider-selection')
      end
    end

    context 'when going to another branch' do
      let(:step_params) { { test_do_you_know_which_course: { answer: 'no' } } }

      before do
        # The named route is dynamic by form so we don't have the named route
        # for this spec.
        #
        without_partial_double_verification do
          allow(wizard.url_helpers).to receive(:test_wizard_test_go_to_find_path).and_return('/go-to-find')
        end
      end

      it 'returns the named routes for the next step' do
        expect(wizard.next_step_path).to eq('/go-to-find')
      end
    end

    context 'when needs for more arguments' do
      let(:current_step) { :test_provider_selection }
      let(:step_params) { { test_provider_selection: { provider_id: 10 } } }

      before do
        # The named route is dynamic by form so we don't have the named route
        # for this spec.
        #
        without_partial_double_verification do
          allow(wizard.url_helpers).to receive(:test_wizard_test_course_name_selection_path).with({ provider_id: 10 }).and_return('/provider/10/courses')
        end
      end

      it 'returns the named routes for the next step' do
        expect(wizard.next_step_path).to eq('/provider/10/courses')
      end
    end
  end

  describe '#save' do
    context 'when store service exists' do
      it 'calls save on wizard' do
        expect(wizard.save).to be(:save_from_store_service)
      end

      it 'pass the wizard as attribute' do
        expect(wizard.store).to be_instance_of(TestWizard::MyAwesomeStoreService)
        expect(wizard.store.wizard).to be(wizard)
      end
    end

    context 'when store service does not exist' do
      subject(:wizard) { TestWizard::AnotherWizard.new(current_step: :test_another_wizard_first) }

      it 'returns false' do
        expect(wizard.save).to be_falsey
      end
    end
  end
end

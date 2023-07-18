require 'rails_helper'

module TestWizard
  class TestDoYouKnowWhichCourse < DfE::WizardStep
    attr_accessor :answer
    validates :answer, presence: true

    def self.permitted_params
      [:answer]
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
  end

  class TestGoToFindStep < DfE::WizardStep
  end

  class MyAwesomeCourseSelectionWizard < DfE::Wizard
    steps do
      [
        {
          test_do_you_know_which_course: TestDoYouKnowWhichCourse,
          test_go_to_find: TestGoToFindStep,
          test_provider_selection: TestProviderSelection,
        },
      ]
    end
  end
end

RSpec.describe DfE::Wizard do
  subject(:wizard) { TestWizard::MyAwesomeCourseSelectionWizard.new(current_step:, step_params:) }

  let(:step_params) { {} }

  describe '.steps' do
    it 'returns the steps declared in the block' do
      expect(TestWizard::MyAwesomeCourseSelectionWizard.steps).to eq(
        [
          {
            test_do_you_know_which_course: TestWizard::TestDoYouKnowWhichCourse,
            test_go_to_find: TestWizard::TestGoToFindStep,
            test_provider_selection: TestWizard::TestProviderSelection,
          },
        ],
      )
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
end

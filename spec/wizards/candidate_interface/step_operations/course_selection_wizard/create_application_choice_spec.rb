require 'rails_helper'

RSpec.describe CandidateInterface::StepOperations::CourseSelectionWizard::CreateApplicationChoice, type: :model do
  subject(:create_application_choice) do
    described_class.new(repository:, step: wizard.current_step)
  end

  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:state_store) { CandidateInterface::StateStores::CourseSelectionWizardStore.new(repository:) }
  let(:wizard) do
    CandidateInterface::CourseSelectionWizard.new(
      current_step:,
      current_step_params:,
      state_store:,
    ).tap do |wizard|
      wizard.current_application = current_application
    end
  end
  let(:current_application) { create(:completed_application_form) }
  let(:current_step) { :which_course_are_you_applying_to }
  let(:current_step_params) { {} }
  let(:course) { create(:course, :open) }
  let(:provider) { course.provider }
  let(:course_option) { create(:course_option, :full_time, course:) }

  describe 'delegations' do
    it { is_expected.to delegate_method(:completed?).to(:current_step) }
  end

  describe '.execute' do
    before do
      course_option
      state_store.write(
        current_application_id: current_application.id,
        course_id: course.id,
        provider_id: provider.id,
      )
    end

    subject(:execute) { create_application_choice.execute }

    context 'when the current step is complete' do
      it 'creates an application choice' do
        expect { execute }.to change(ApplicationChoice, :count).by(1)
        new_application_choice = current_application.application_choices.last
        expect(new_application_choice.course).to eq(course)
        expect(new_application_choice.provider).to eq(provider)
      end
    end

    context 'when the current step is not complete' do
      before { create(:course_option, :part_time, course:) }

      it 'creates an application choice' do
        expect { execute }.not_to change(ApplicationChoice, :count)
      end
    end

    context 'editing an existing application choice' do
      let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: current_application) }

      before do
        state_store.write(application_choice_id: application_choice.id)
      end

      it 'updates the application choice' do
        expect { execute }.not_to change(ApplicationChoice, :count)
        application_choice.reload
        expect(application_choice.course).to eq(course)
        expect(application_choice.provider).to eq(provider)
      end
    end

    context 'when a duplicate course application exists' do
      let(:duplicate_application_choice) do
        create(
          :application_choice,
          :awaiting_provider_decision,
          application_form: current_application,
          course_option:,
        )
      end

      before { duplicate_application_choice }

      context 'when current step is which_course_are_you_applying_to' do
        it 'does not raise an error' do
          expect { execute }.not_to raise_error
        end

        it 'does not change the number of application choices' do
          expect { execute }.not_to change(ApplicationChoice, :count)
        end

        it 'returns an error message regarding the step not being completed' do
          expect(execute[:message]).to eq('Step not completed')
        end
      end

      context 'when current step is find_course_selection' do
        let(:current_step) { :find_course_selection }

        it 'does not raise an error' do
          expect { execute }.not_to raise_error
        end

        it 'does not change the number of application choices' do
          expect { execute }.not_to change(ApplicationChoice, :count)
        end

        it 'returns an error message regarding the step not being completed' do
          expect(execute[:message]).to eq('Step not completed')
        end
      end

      context 'when current step is course site' do
        let(:current_step) { :course_site }

        it 'does not raise an error' do
          expect { execute }.not_to raise_error
        end

        it 'does not change the number of application choices' do
          expect { execute }.not_to change(ApplicationChoice, :count)
        end

        it 'returns an error message regarding a duplicate course' do
          expect(execute[:message]).to eq('Application for this course already exists')
        end
      end
    end
  end
end

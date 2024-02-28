RSpec.shared_examples 'confirm deferred offer validations' do |transition_event|
  context 'checks the course option is present' do
    let(:new_course_option) { nil }

    it 'raises a ValidationException' do
      expect { service.save! }
        .to raise_error(ValidationException, 'The offered course does not exist in this recruitment cycle')
    end
  end

  context 'checks course option matches the current RecruitmentCycle' do
    let(:new_course_option) { previous_course_option }

    it 'raises a ValidationException' do
      expect { service.save! }
        .to raise_error(ValidationException, 'Only applications deferred in the previous recruitment cycle can be confirmed')
    end
  end

  context 'when the application is not in a state allowing to reinstate conditions met' do
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision,
             course_option: previous_course_option)
    end

    it 'raises a Workflow::NoTransitionAllowed error' do
      expect { service.save! }
        .to raise_error(Workflow::NoTransitionAllowed,
                        "There is no event #{transition_event} defined for the awaiting_provider_decision state")
    end
  end
end

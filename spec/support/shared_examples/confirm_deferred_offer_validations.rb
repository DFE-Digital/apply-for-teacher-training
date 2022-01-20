RSpec.shared_examples 'confirm deferred offer validations' do |transition_event|
  context 'checks the course option is present' do
    let(:new_course_option) { nil }

    it 'save! raises a ValidationException' do
      expect { service.save! }
        .to raise_error(ValidationException, 'Please provide a course_option or course_option_id')
    end

    it 'save returns false' do
      expect(service.save).to be false
    end
  end

  context 'checks the course is open on apply' do
    let(:new_course_option) do
      create(:course_option,
             course: create(:course, provider: provider, open_on_apply: false))
    end

    it 'save! raises a ValidationException' do
      expect { service.save! }
        .to raise_error(ValidationException, 'The requested course is not open for applications via the Apply service')
    end

    it 'save returns false' do
      expect(service.save).to be false
    end
  end

  context 'checks course option matches the current RecruitmentCycle' do
    let(:new_course_option) { previous_course_option }

    it 'save! raises a ValidationException' do
      expect { service.save! }
        .to raise_error(ValidationException, 'The requested course does not exist in the current cycle')
    end

    it 'save returns false' do
      expect(service.save).to be false
    end
  end

  context 'when the application is not in a state allowing to reinstate conditions met' do
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision,
             course_option: previous_course_option)
    end

    it 'save! raises a Workflow::NoTransitionAllowed error' do
      expect { service.save!  }
        .to raise_error(Workflow::NoTransitionAllowed,
                        "There is no event #{transition_event} defined for the awaiting_provider_decision state")
    end

    it 'save returns false' do
      expect(service.save).to be false
    end
  end
end

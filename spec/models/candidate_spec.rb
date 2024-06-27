require 'rails_helper'

RSpec.describe Candidate do
  before do
    TestSuiteTimeMachine.unfreeze!
  end

  describe 'a valid candidate' do
    subject { create(:candidate) }

    it_behaves_like 'an email address valid for notify'

    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
    it { is_expected.not_to allow_value('foo').for(:email_address) }
    it { is_expected.not_to allow_value(Faker::Lorem.characters(number: 251)).for(:email_address) }
  end

  describe 'before_save' do
    context 'with application choices' do
      it 'touches the application choice when a field affecting the application choice is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(email_address: 'new.email@example.com') }
          .to(change { application_form.application_choices.first.updated_at })
      end

      it 'does not touch the application choice when a field not affecting the application choice is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(last_signed_in_at: Time.zone.now) }
          .not_to(change { application_form.application_choices.first.updated_at })
      end

      it 'does not touch the application choice when its in a previous recruitment cycle' do
        candidate = create(:candidate)
        application_choice = create(:application_choice, current_recruitment_cycle_year: RecruitmentCycle.previous_year)
        application_form = ApplicationForm.with_unsafe_application_choice_touches do
          create(:completed_application_form, application_choices: [application_choice], candidate:, recruitment_cycle_year: RecruitmentCycle.previous_year)
        end

        expect { candidate.update(email_address: 'new.email@example.com') }
          .not_to(change { application_form.application_choices.first.updated_at })
      end
    end

    context 'with application forms' do
      it 'touches the application form when a field affecting the application form is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(email_address: 'new.email@example.com') }
          .to(change { application_form.reload.updated_at })
      end

      it 'does not touch the application form when a field not affecting the application form is changed' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, application_choices_count: 1, candidate:)

        expect { candidate.update(last_signed_in_at: Time.zone.now) }
          .not_to(change { application_form.reload.updated_at })
      end

      it 'does not touch the application form when its in a previous recruitment cycle' do
        candidate = create(:candidate)
        application_form = ApplicationForm.with_unsafe_application_choice_touches do
          create(:completed_application_form, application_choices_count: 1, candidate:, recruitment_cycle_year: RecruitmentCycle.previous_year)
        end

        expect { candidate.update(email_address: 'new.email@example.com') }
          .not_to(change { application_form.reload.updated_at })
      end
    end
  end

  describe '#delete' do
    it 'deletes all dependent records through cascading deletes in the database' do
      candidate = create(:candidate)
      application_form = create(:application_form, candidate:)
      application_choice = create(:application_choice, application_form:)
      application_work_experience = create(:application_work_experience, application_form:)
      application_volunteering_experience = create(:application_volunteering_experience, application_form:)
      application_qualification = create(:application_qualification, application_form:)
      application_reference = create(:reference, application_form:)

      candidate.delete

      expect { candidate.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_form.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_choice.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_work_experience.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_volunteering_experience.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_qualification.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_reference.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#current_application' do
    let(:candidate) { create(:candidate) }

    context 'mid cycle' do
      around do |example|
        travel_temporarily_to(CycleTimetable.find_opens + 1.day) do
          example.run
        end
      end

      it 'returns an existing application_form' do
        application_form = create(:application_form, candidate:)

        expect(candidate.current_application).to eq(application_form)
      end

      it 'creates an application_form with the current cycle if there are none' do
        expect { candidate.current_application }.to change { candidate.application_forms.count }.from(0).to(1)
        expect(candidate.current_application.recruitment_cycle_year).to eq CycleTimetable.current_year
      end

      it 'returns the most recent application' do
        first_application = create(:application_form, candidate:, created_at: 3.days.ago)
        create(:application_form, candidate:, created_at: 10.days.ago)

        expect(candidate.current_application.created_at).to eq(first_application.created_at)
      end
    end

    context 'after the apply deadline' do
      around do |example|
        travel_temporarily_to(CycleTimetable.apply_deadline + 1.day) do
          example.run
        end
      end

      it 'returns an existing application_form' do
        application_form = create(:application_form, candidate:)

        expect(candidate.current_application).to eq(application_form)
      end

      it 'creates an application_form in the next cycle if there are none' do
        expect { candidate.current_application }.to change { candidate.application_forms.count }.from(0).to(1)
        expect(candidate.current_application.recruitment_cycle_year).to eq CycleTimetable.next_year
      end
    end
  end

  describe '#current_application_choices' do
    let(:candidate) { create(:candidate) }

    context 'with a single application choice' do
      let!(:application_choice) { create(:application_choice, candidate:) }

      it 'returns the application choice' do
        expect(candidate.current_application_choices).to contain_exactly(application_choice)
      end
    end

    context 'with multiple application choices' do
      let(:application_choice_2) { create(:application_choice, candidate:, created_at: 1.day.ago) }
      let(:application_choice_1) { create(:application_choice, candidate:, created_at: 1.week.ago) }
      let(:application_choice_3) { create(:application_choice, candidate:) }
      let!(:application_form) { create(:application_form, candidate:, application_choices: [application_choice_2, application_choice_1, application_choice_3]) }

      it 'returns all the application choices' do
        expect(candidate.current_application_choices).to contain_exactly(application_choice_1, application_choice_2, application_choice_3)
      end
    end

    context 'with applications in different phases' do
      let(:application_choice_1) { create(:application_choice, candidate:) }
      let(:application_choice_2) { create(:application_choice, candidate:) }
      let(:application_choice_3) { create(:application_choice, candidate:) }
      let!(:application_form_apply_1) { create(:application_form, candidate:, application_choices: [application_choice_1], created_at: 1.week.ago) }
      let!(:application_form_apply_2) { create(:application_form, phase: 'apply_2', candidate:, application_choices: [application_choice_2, application_choice_3]) }

      it 'returns the most recent application choices' do
        expect(candidate.current_application_choices).to contain_exactly(application_choice_2, application_choice_3)
      end
    end
  end

  describe 'find_from_course' do
    it 'returns the correct course' do
      course = create(:course)
      candidate = create(:candidate, course_from_find_id: course.id)

      expect(candidate.course_from_find).to eq(course)
    end

    it 'returns nil if there is no course_from_find_id' do
      candidate = create(:candidate)

      expect(candidate.course_from_find).to be_nil
    end
  end

  describe '#encrypted_id' do
    let(:candidate) { create(:candidate) }

    it 'invokes Encryptor to encrypt id' do
      allow(Encryptor).to receive(:encrypt).with(candidate.id).and_return 'encrypted id value'

      expect(candidate.encrypted_id).to eq 'encrypted id value'
    end
  end

  describe '#in_apply_2?' do
    subject(:candidate) { build(:candidate) }

    let!(:application_form) { create(:application_form, candidate:) }

    context 'when the candidate has no applications in apply again' do
      it 'returns false' do
        expect(candidate.in_apply_2?).to be false
      end
    end

    context 'when the candidate has applications in apply again' do
      let!(:application_form) { create(:application_form, candidate:, phase: 'apply_2') }

      it 'returns true' do
        expect(candidate.in_apply_2?).to be true
      end
    end

    context 'when the candidate has applications in apply again in previous cycle' do
      let!(:application_form_previous_year) { create(:application_form, candidate:, phase: 'apply_2', recruitment_cycle_year: RecruitmentCycle.previous_year) }
      let!(:application_form) { create(:application_form, candidate:) }

      it 'returns true' do
        expect(candidate.in_apply_2?).to be false
      end
    end
  end

  describe '#load_tester?' do
    context 'environment is production' do
      before { allow(HostingEnvironment).to receive(:production?).and_return true }

      it 'returns false regardless of the email address pattern' do
        candidate = build(:candidate, email_address: 'someone@loadtest.example.com')
        expect(candidate).not_to be_load_tester
        candidate.email_address = 'someone@example.com'
        expect(candidate).not_to be_load_tester
      end
    end

    context 'environment is not production' do
      before { allow(HostingEnvironment).to receive(:production?).and_return false }

      it 'returns true if email address is for load testing' do
        candidate = build(:candidate, email_address: 'someone@loadtest.example.com')
        expect(candidate).to be_load_tester
      end

      it 'returns false if email is not for load testing' do
        candidate = build(:candidate, email_address: 'someone@example.com')
        expect(candidate).not_to be_load_tester
      end
    end
  end

  describe '#pseudonymised_id' do
    it 'returns the pseudonymised id based on the candidate id' do
      candidate = build_stubbed(:candidate, id: 0)
      expect(candidate.pseudonymised_id).to eq '5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9'
    end
  end
end

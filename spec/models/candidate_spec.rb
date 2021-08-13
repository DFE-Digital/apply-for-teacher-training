require 'rails_helper'

RSpec.describe Candidate, type: :model do
  describe 'a valid candidate' do
    subject { create(:candidate) }

    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
    it { is_expected.to allow_value('user@example.com').for(:email_address) }
    it { is_expected.not_to allow_value('foo').for(:email_address) }
    it { is_expected.not_to allow_value(Faker::Lorem.characters(number: 251)).for(:email_address) }
  end

  describe '#delete' do
    it 'deletes all dependent records through cascading deletes in the database' do
      candidate = create(:candidate)
      application_form = create(:application_form, candidate: candidate)
      application_choice = create(:application_choice, application_form: application_form)
      application_work_experience = create(:application_work_experience, application_form: application_form)
      application_volunteering_experience = create(:application_volunteering_experience, application_form: application_form)
      application_qualification = create(:application_qualification, application_form: application_form)
      application_reference = create(:reference, application_form: application_form)
      ucas_match = create(:ucas_match, candidate: candidate)

      candidate.delete

      expect { candidate.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_form.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_choice.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_work_experience.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_volunteering_experience.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_qualification.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { application_reference.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { ucas_match.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#current_application' do
    let(:candidate) { create(:candidate) }

    context 'mid cycle' do
      around do |example|
        Timecop.travel(CycleTimetable.find_opens + 1.day) do
          example.run
        end
      end

      it 'returns an existing application_form' do
        application_form = create(:application_form, candidate: candidate)

        expect(candidate.current_application).to eq(application_form)
      end

      it 'creates an application_form with the current cycle if there are none' do
        expect { candidate.current_application }.to change { candidate.application_forms.count }.from(0).to(1)
        expect(candidate.current_application.recruitment_cycle_year).to eq CycleTimetable.current_year
      end

      it 'returns the most recent application' do
        first_application = create(:application_form, candidate: candidate, created_at: 3.days.ago)
        create(:application_form, candidate: candidate, created_at: 10.days.ago)

        expect(candidate.current_application.created_at).to eq(first_application.created_at)
      end
    end

    context 'after the apply1 deadline' do
      around do |example|
        Timecop.travel(CycleTimetable.apply_1_deadline + 1.day) do
          example.run
        end
      end

      it 'returns an existing application_form' do
        application_form = create(:application_form, candidate: candidate)

        expect(candidate.current_application).to eq(application_form)
      end

      it 'creates an application_form in the next cycle if there are none' do
        expect { candidate.current_application }.to change { candidate.application_forms.count }.from(0).to(1)
        expect(candidate.current_application.recruitment_cycle_year).to eq CycleTimetable.next_year
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

      expect(candidate.course_from_find).to eq(nil)
    end
  end

  describe '#encrypted_id' do
    let(:candidate) { create(:candidate) }

    it 'invokes Encryptor to encrypt id' do
      allow(Encryptor).to receive(:encrypt).with(candidate.id).and_return 'encrypted id value'

      expect(candidate.encrypted_id).to eq 'encrypted id value'
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
end

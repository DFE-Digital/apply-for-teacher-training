require 'rails_helper'

RSpec.describe CopyIncidentApplicationToNewAccount do
  before do
    travel_temporarily_to(-1.day) do
      @original_application_form = create(
        :completed_application_form,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        full_work_history: true,
        recruitment_cycle_year: RecruitmentCycle.current_year,
        references_count: 0,
      )
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @original_application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: @original_application_form)
    end
  end

  context 'when candidate does not have an existing application form' do
    it 'copies the original application to the new candidate in current recruitment cycle' do
      another_candidate = create(:candidate)
      another_candidate.application_forms.delete_all
      duplicate_application_form = described_class.new(
        original_application_form: @original_application_form,
        candidate_email_address: another_candidate.email_address,
      ).call!

      expect(duplicate_application_form).to be_becoming_a_teacher_completed
      expect(duplicate_application_form.candidate_id).to be(another_candidate.id)
      expect(duplicate_application_form.recruitment_cycle_year).to be(RecruitmentCycle.current_year)
      expect(another_candidate.current_application.previous_application_form).to be_nil
    end
  end

  context 'when candidate does have an application form in previous cycle' do
    it 'copies the original application to the new candidate in current recruitment cycle with a link to their previous application' do
      another_candidate = create(:candidate)
      previous_cycle_application_form = create(:application_form, becoming_a_teacher_completed: false, recruitment_cycle_year: RecruitmentCycle.previous_year, candidate: another_candidate)
      duplicate_application_form = described_class.new(
        original_application_form: @original_application_form,
        candidate_email_address: another_candidate.email_address,
      ).call!

      expect(duplicate_application_form).to be_becoming_a_teacher_completed
      expect(duplicate_application_form.candidate_id).to be(another_candidate.id)
      expect(duplicate_application_form.recruitment_cycle_year).to be(RecruitmentCycle.current_year)
      expect(duplicate_application_form.previous_application_form_id).to eq(previous_cycle_application_form.id)
      expect(duplicate_application_form.previous_application_form).to eq(previous_cycle_application_form)
      expect(another_candidate.current_application.previous_application_form).to eq(previous_cycle_application_form)
    end
  end

  context 'when candidate does have an application form in current cycle' do
    it 'assigns the original application as current application for the candidate in current cycle' do
      another_candidate = create(:candidate)
      current_cycle_application_form = create(:application_form, becoming_a_teacher_completed: false, created_at: 1.day.ago, candidate: another_candidate)

      duplicate_application_form = described_class.new(
        original_application_form: @original_application_form,
        candidate_email_address: another_candidate.email_address,
      ).call!

      expect(duplicate_application_form).to be_becoming_a_teacher_completed
      expect(duplicate_application_form.candidate_id).to be(another_candidate.id)
      expect(duplicate_application_form.recruitment_cycle_year).to be(RecruitmentCycle.current_year)

      expect(duplicate_application_form.created_at).to be > current_cycle_application_form.created_at
      expect(another_candidate.current_application).to eq(duplicate_application_form)
      expect(duplicate_application_form.previous_application_form_id).to eq(current_cycle_application_form.id)
      expect(another_candidate.current_application.previous_application_form).to eq(current_cycle_application_form)
    end
  end

  context 'when candidate account does not exist' do
    context 'when has application choices' do
      before do
        @first_choice = create(:application_choice, :awaiting_provider_decision, application_form: @original_application_form)
        @second_choice = create(:application_choice, :awaiting_provider_decision, application_form: @original_application_form)
        @unsubmitted_choice = create(:application_choice, :unsubmitted, application_form: @original_application_form)
      end

      it 'creates new candidate with new emails address' do
        duplicate_application_form = described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'some.email@example.com',
        ).call!
        expect(duplicate_application_form.candidate).to be_persisted
        expect(duplicate_application_form.candidate.email_address).to eq('some.email@example.com')
      end

      it 'creates one candidate with same emails address but in uppercase' do
        duplicate_application_form = described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'some.email@example.com',
        ).call!
        described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'SOME.EMAIL@example.com',
        ).call!
        described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'SOME.EMAIL@example.com',
        ).call!
        expect(Candidate.pluck(:id)).to contain_exactly(@original_application_form.candidate_id, duplicate_application_form.candidate_id)
      end

      it 'copies application choices in awaiting provider decision' do
        duplicate_application_form = described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'some.email@example.com',
        ).call!

        expect(duplicate_application_form.application_choices.map(&:current_course).map(&:name)).to contain_exactly(@first_choice.current_course.name, @second_choice.current_course.name, @unsubmitted_choice.current_course.name)
        expect(duplicate_application_form.application_choices.map(&:provider)).to contain_exactly(@first_choice.provider, @second_choice.provider, @unsubmitted_choice.provider)

        expect(duplicate_application_form.application_choices.awaiting_provider_decision.count).to be 2
        expect(duplicate_application_form.application_choices.unsubmitted.count).to be 1

        expect(duplicate_application_form.application_choices.reload.pluck(:personal_statement)).to contain_exactly(@unsubmitted_choice.personal_statement, @first_choice.personal_statement, @second_choice.personal_statement)
      end
    end

    context 'when does not have application choices' do
      it 'does not create application choices' do
        duplicate_application_form = described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'some.email@example.com',
        ).call!
        expect(duplicate_application_form.application_choices).to be_empty
      end
    end

    context 'when qualification has constituent grades' do
      it 'generates a new public id for each constituent grade' do
        create(
          :gcse_qualification,
          :multiple_english_gcses,
          constituent_grades: {
            english_language: { grade: 'A', public_id: 120282 },
            english_literature: { grade: 'D', public_id: 120283 },
          },
          application_form: @original_application_form,
        )

        duplicate_application_form = described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'some.email@example.com',
        ).call!

        expect(duplicate_application_form.application_qualifications.gcses.count).to be 1
        expect(
          duplicate_application_form.application_qualifications.gcses.first.constituent_grades['english_language']['public_id'],
        ).not_to be 120282
        expect(duplicate_application_form.application_qualifications.gcses.first.constituent_grades['english_literature']['public_id']).not_to be 120283
      end
    end

    context 'when references section is completed on original application form' do
      it 'marks as references section as completed' do
        @original_application_form.update!(references_completed: true)

        duplicate_application_form = described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'some.email@example.com',
        ).call!

        expect(duplicate_application_form).to be_references_completed
      end
    end

    context 'when references section is not completed on original application form' do
      it 'marks as references section as incomplete' do
        @original_application_form.update!(references_completed: false)

        duplicate_application_form = described_class.new(
          original_application_form: @original_application_form,
          candidate_email_address: 'some.email@example.com',
        ).call!

        expect(duplicate_application_form).not_to be_references_completed
      end
    end
  end
end

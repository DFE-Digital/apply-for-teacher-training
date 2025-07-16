require 'rails_helper'

RSpec.describe FindACandidate::PopulatePoolWorker do
  describe '#peform after the apply deadline,', time: after_apply_deadline do
    it 'does not create any CandidatePoolApplication records' do
      application_form = create(:application_form, :completed, submitted_application_choices_count: 1)
      create(
        :candidate_preference,
        candidate: application_form.candidate,
      )
      stub_application_forms_in_the_pool(application_form.id)

      expect {
        described_class.new.perform
      }.not_to(change { CandidatePoolApplication.count })

      expect(CandidatePoolApplication.count).to eq(0)
    end

    it 'deletes all records if any exists' do
      create(:candidate_pool_application)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(1).to(0)
    end
  end

  describe '#peform before apply opens,', time: before_apply_opens do
    it 'does not create any CandidatePoolApplication records' do
      application_form = create(:application_form, :completed, submitted_application_choices_count: 1)
      create(
        :candidate_preference,
        candidate: application_form.candidate,
      )
      stub_application_forms_in_the_pool(application_form.id)

      expect {
        described_class.new.perform
      }.not_to(change { CandidatePoolApplication.count })

      expect(CandidatePoolApplication.count).to eq(0)
    end

    it 'deletes all records if any exists' do
      create(:candidate_pool_application)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(1).to(0)
    end
  end

  describe '#perform before the apply deadline', time: mid_cycle do
    it 'creates CandidatePoolApplication records' do
      application_form = create(:application_form, :completed, submitted_application_choices_count: 1)
      create(
        :candidate_preference,
        candidate: application_form.candidate,
      )
      stub_application_forms_in_the_pool(application_form.id)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(0).to(1)

      expect(CandidatePoolApplication.last.application_form).to eq(application_form)
    end

    it 'does not create duplicate CandidatePoolApplication records' do
      application_form = create(:application_form, :completed, submitted_application_choices_count: 1)
      create(
        :candidate_preference,
        candidate: application_form.candidate,
      )
      create(:candidate_pool_application, application_form: application_form)
      stub_application_forms_in_the_pool(application_form.id)

      expect {
        described_class.new.perform
      }.not_to(change { CandidatePoolApplication.count })
    end

    it 'removes existing CandidatePoolApplication records before inserting new ones' do
      application_form = create(:application_form, :completed, submitted_application_choices_count: 1)
      create(
        :candidate_preference,
        candidate: application_form.candidate,
      )
      create(:candidate_pool_application, application_form: application_form)
      stub_application_forms_in_the_pool(ApplicationForm.none)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(1).to(0)
    end

    it 'removes existing and adds new CandidatePoolApplication records' do
      existing_application_in_pool = create(:application_form, :completed, submitted_application_choices_count: 1)
      new_application_for_pool = create(:application_form, :completed, submitted_application_choices_count: 1)
      create(
        :candidate_preference,
        candidate: new_application_for_pool.candidate,
      )
      create(:candidate_pool_application, application_form: existing_application_in_pool)
      stub_application_forms_in_the_pool(new_application_for_pool.id)

      expect {
        described_class.new.perform
      }.not_to(change { CandidatePoolApplication.count })

      expect(CandidatePoolApplication.last.application_form).to eq(new_application_for_pool)
    end

    context 'when the candidate has applied to a full-time course' do
      it 'sets study_mode_full_time to true' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        course_option = create(:course_option, study_mode: 'full_time')
        _application_choice = create(:application_choice,
                                     status: :awaiting_provider_decision,
                                     application_form: application_form,
                                     course_option: course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.study_mode_full_time).to be true
      end
    end

    context 'when the candidate has applied to a part-time course' do
      it 'sets study_mode_part_time to true' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        course_option = create(:course_option, study_mode: 'part_time')
        _application_choice = create(:application_choice,
                                     status: :awaiting_provider_decision,
                                     application_form: application_form,
                                     course_option: course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.study_mode_part_time).to be true
      end
    end

    context 'when the candidate has applied to both full-time and part-time courses' do
      it 'sets both study_mode_full_time and study_mode_part_time to true' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        full_time_course_option = create(:course_option, study_mode: 'full_time')
        part_time_course_option = create(:course_option, study_mode: 'part_time')
        _application_choice1 = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: full_time_course_option)
        _application_choice2 = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: part_time_course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.study_mode_full_time).to be true
        expect(candidate_pool_application.study_mode_part_time).to be true
      end

      context 'when one of the application choices is unsubmitted' do
        it 'does not set the study mode based on the unsubmitted choice' do
          application_form = create(:application_form)
          create(
            :candidate_preference,
            candidate: application_form.candidate,
          )
          full_time_course_option = create(:course_option, study_mode: 'full_time')
          part_time_course_option = create(:course_option, study_mode: 'part_time')
          _submitted_full_time_application = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: full_time_course_option)
          _unsubmitted_part_time_application = create(:application_choice, status: :unsubmitted, application_form: application_form, course_option: part_time_course_option)
          stub_application_forms_in_the_pool(application_form.id)

          described_class.new.perform

          candidate_pool_application = CandidatePoolApplication.last
          expect(candidate_pool_application.study_mode_full_time).to be true
          expect(candidate_pool_application.study_mode_part_time).to be false
        end
      end
    end

    context 'when the candidate has applied to a postgraduate course' do
      it 'sets course_type_postgraduate to true' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        course_option = create(:course_option, course: create(:course, program_type: 'higher_education_programme'))
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: course_option)

        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_type_postgraduate).to be true
      end
    end

    context 'when the candidate has applied to an undergraduate course' do
      it 'sets course_type_undergraduate to true' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        course_option = create(:course_option, course: create(:course, program_type: 'teacher_degree_apprenticeship'))
        create(:application_choice,
               status: :awaiting_provider_decision,
               application_form: application_form,
               course_option: course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_type_undergraduate).to be true
      end
    end

    context 'when the candidate has applied to both postgraduate and undergraduate courses' do
      it 'sets both course_type_postgraduate and course_type_undergraduate to true' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        postgraduate_course_option = create(:course_option, course: create(:course, program_type: 'higher_education_programme'))
        undergraduate_course_option = create(:course_option, course: create(:course, program_type: 'teacher_degree_apprenticeship'))
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: postgraduate_course_option)
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: undergraduate_course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_type_postgraduate).to be true
        expect(candidate_pool_application.course_type_undergraduate).to be true
      end

      context 'when one of the application choices is unsubmitted' do
        it 'does not set the course type based on the unsubmitted choice' do
          application_form = create(:application_form)
          create(
            :candidate_preference,
            candidate: application_form.candidate,
          )
          postgraduate_course_option = create(:course_option, course: create(:course, program_type: 'higher_education_programme'))
          undergraduate_course_option = create(:course_option, course: create(:course, program_type: 'teacher_degree_apprenticeship'))
          _submitted_postgraduate_application = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: postgraduate_course_option)
          _unsubmitted_undergraduate_application = create(:application_choice, status: :unsubmitted, application_form: application_form, course_option: undergraduate_course_option)
          stub_application_forms_in_the_pool(application_form.id)

          described_class.new.perform

          candidate_pool_application = CandidatePoolApplication.last
          expect(candidate_pool_application.course_type_postgraduate).to be true
          expect(candidate_pool_application.course_type_undergraduate).to be false
        end
      end
    end

    context 'populating subject_ids' do
      it 'sets subject_ids to the subjects of the courses' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        subject = create(:subject)
        course_option = create(:course_option, course: create(:course, subjects: [subject]))
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.subject_ids).to eq([subject.id])
      end

      it 'sets subject_ids to unique subjects of all courses' do
        application_form = create(:application_form)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        subject1 = create(:subject, id: 999991) # id set to ensure we're not picking up some other id
        subject2 = create(:subject, id: 999992) # id set to ensure we're not picking up some other id
        course_option1 = create(:course_option, course: create(:course, subjects: [subject1]))
        course_option2 = create(:course_option, course: create(:course, subjects: [subject2]))
        course_option3 = create(:course_option, course: create(:course, subjects: [subject1, subject2]))
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: course_option1)
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: course_option2)
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: course_option3)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.subject_ids).to contain_exactly(subject1.id, subject2.id)
      end

      context 'when one of the application choices is unsubmitted' do
        it 'does not set the subject ids based on the unsubmitted choice' do
          application_form = create(:application_form)
          create(
            :candidate_preference,
            candidate: application_form.candidate,
          )
          subject1 = create(:subject, id: 999991) # id set to ensure we're not picking up some other id
          subject2 = create(:subject, id: 999992) # id set to ensure we're not picking up some other id
          course_option1 = create(:course_option, course: create(:course, subjects: [subject1]))
          course_option2 = create(:course_option, course: create(:course, subjects: [subject2]))
          create(:application_choice, status: :awaiting_provider_decision, application_form: application_form, course_option: course_option1)
          create(:application_choice, status: :unsubmitted, application_form: application_form, course_option: course_option2)
          stub_application_forms_in_the_pool(application_form.id)

          described_class.new.perform

          candidate_pool_application = CandidatePoolApplication.last
          expect(candidate_pool_application.subject_ids).to contain_exactly(subject1.id)
        end
      end
    end

    context 'when the application form has not answered right_to_work_or_study' do
      it 'sets needs_visa to false' do
        application_form = create(:application_form, :completed,
                                  submitted_application_choices_count: 1,
                                  right_to_work_or_study: nil)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.needs_visa).to be false
      end
    end

    context 'when the application form answered decide_later to right_to_work_or_study' do
      it 'sets needs_visa to false' do
        application_form = create(:application_form, :completed,
                                  submitted_application_choices_count: 1,
                                  right_to_work_or_study: :decide_later)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.needs_visa).to be false
      end
    end

    context 'when the application form answered no to right_to_work_or_study' do
      it 'sets needs_visa to true' do
        application_form = create(:application_form, :completed,
                                  submitted_application_choices_count: 1,
                                  right_to_work_or_study: :no)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.needs_visa).to be true
      end
    end

    context 'when the application form answered yes to right_to_work_or_study' do
      context 'and the immigration status is student_visa' do
        it 'sets needs_visa to true' do
          application_form = create(:application_form, :completed,
                                    submitted_application_choices_count: 1,
                                    right_to_work_or_study: :yes,
                                    immigration_status: 'student_visa')
          create(
            :candidate_preference,
            candidate: application_form.candidate,
          )
          stub_application_forms_in_the_pool(application_form.id)

          described_class.new.perform

          candidate_pool_application = CandidatePoolApplication.last
          expect(candidate_pool_application.needs_visa).to be true
        end
      end

      context 'and the immigration status is skilled_worker_visa' do
        it 'sets needs_visa to true' do
          application_form = create(:application_form, :completed,
                                    submitted_application_choices_count: 1,
                                    right_to_work_or_study: :yes,
                                    immigration_status: 'skilled_worker_visa')
          create(
            :candidate_preference,
            candidate: application_form.candidate,
          )
          stub_application_forms_in_the_pool(application_form.id)

          described_class.new.perform

          candidate_pool_application = CandidatePoolApplication.last
          expect(candidate_pool_application.needs_visa).to be true
        end
      end

      context 'and the immigration status is any other value' do
        it 'sets needs_visa to false' do
          application_form = create(:application_form, :completed,
                                    submitted_application_choices_count: 1,
                                    right_to_work_or_study: :yes,
                                    immigration_status: 'eu_settled')
          create(
            :candidate_preference,
            candidate: application_form.candidate,
          )
          stub_application_forms_in_the_pool(application_form.id)

          described_class.new.perform

          candidate_pool_application = CandidatePoolApplication.last
          expect(candidate_pool_application.needs_visa).to be false
        end
      end
    end

    context 'rejected_provider_ids' do
      it 'sets to [] when there are no rejections' do
        application_form = create(:application_form, :completed, submitted_application_choices_count: 1)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        stub_application_forms_in_the_pool(application_form.id)

        expect(application_form.application_choices.rejected).to eq []

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.rejected_provider_ids).to eq []
      end

      it 'does not include provider ids from choices with other statuses' do
        application_form = create(:application_form, :completed)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        rejected_choice = create(:application_choice, :rejected, application_form:)
        another_reject_choice = create(:application_choice, :rejected, application_form:)
        create(:application_choice, :withdrawn, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.rejected_provider_ids)
          .to contain_exactly(rejected_choice.course.provider_id, another_reject_choice.course.provider.id)
      end

      it 'only collects uniq provider ids' do
        provider = create(:provider)
        first_rejected_course = create(:course, provider:)
        second_rejected_course = create(:course, provider:)

        application_form = create(:application_form, :completed)
        create(
          :candidate_preference,
          candidate: application_form.candidate,
        )
        create(:application_choice, :rejected, application_form:, course_option: build(:course_option, course: first_rejected_course))
        create(:application_choice, :rejected, application_form:, course_option: build(:course_option, course: second_rejected_course))

        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.rejected_provider_ids).to eq([provider.id])
      end
    end

    context 'with course_funding_type_fee' do
      it 'sets course_funding_type_fee true when open to fee funding courses' do
        # this is here to make sure the query is scoped to the correct candidate
        unrelated_form = create(:application_form, :completed)
        create(
          :application_choice,
          application_form: unrelated_form,
          course: create(:course_option, :tda).course,
        )
        application_form = create(
          :application_form,
          :completed,
          submitted_application_choices_count: 1,
        )
        create(
          :candidate_preference,
          candidate: application_form.candidate,
          funding_type: 'fee',
        )

        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_funding_type_fee).to be true
      end

      it 'sets course_funding_type_fee true when open to fee funding courses but applied to salary' do
        unrelated_form = create(:application_form, :completed)
        create(
          :application_choice,
          application_form: unrelated_form,
          course: create(:course_option, :tda).course,
        )
        application_form = create(
          :application_form,
          :completed,
        )
        create(
          :application_choice,
          application_form:,
          course: create(:course_option, :tda).course,
        )
        create(
          :candidate_preference,
          candidate: application_form.candidate,
          funding_type: nil,
        )
        create(
          :candidate_preference,
          candidate: application_form.candidate,
          funding_type: 'fee',
        )

        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_funding_type_fee).to be true
      end

      it 'sets course_funding_type_fee true when applied to fee funded courses but no preference' do
        unrelated_form = create(:application_form, :completed)
        create(
          :application_choice,
          application_form: unrelated_form,
          course: create(:course_option, :tda).course,
        )
        application_form = create(
          :application_form,
          :completed,
        )
        create(
          :application_choice,
          application_form:,
          course: create(:course_option, :fee).course,
        )
        create(
          :application_choice,
          application_form:,
          course: create(:course_option, :tda).course,
        )
        create(
          :candidate_preference,
          candidate: application_form.candidate,
          funding_type: nil,
        )

        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_funding_type_fee).to be true
      end

      it 'sets course_funding_type_fee false when preference is only salary' do
        unrelated_form = create(:application_form, :completed)
        create(
          :application_choice,
          application_form: unrelated_form,
          course: create(:course_option, :fee).course,
        )
        application_form = create(
          :application_form,
          :completed,
        )
        create(
          :application_choice,
          application_form:,
          course: create(:course_option, :fee).course,
        )
        create(
          :application_choice,
          application_form:,
          course: create(:course_option, :tda).course,
        )
        create(
          :candidate_preference,
          candidate: application_form.candidate,
          funding_type: 'salary',
        )

        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_funding_type_fee).to be false
      end

      it 'sets course_funding_type_fee false when no preference but only applied to salary courses' do
        unrelated_form = create(:application_form, :completed)
        create(
          :application_choice,
          application_form: unrelated_form,
          course: create(:course_option, :fee).course,
        )
        application_form = create(
          :application_form,
          :completed,
        )
        create(
          :application_choice,
          application_form:,
          course: create(:course_option, :tda).course,
        )
        create(
          :candidate_preference,
          candidate: application_form.candidate,
          funding_type: nil,
        )

        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.course_funding_type_fee).to be false
      end
    end
  end

private

  def stub_application_forms_in_the_pool(application_form_ids)
    pool_candidates_double = instance_double(Pool::Candidates, application_forms_in_the_pool: ApplicationForm.where(id: application_form_ids))
    allow(Pool::Candidates).to receive(:new).and_return(pool_candidates_double)
  end
end

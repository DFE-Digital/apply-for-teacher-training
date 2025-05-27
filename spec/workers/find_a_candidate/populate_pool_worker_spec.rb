require 'rails_helper'

RSpec.describe FindACandidate::PopulatePoolWorker do
  describe '#perform' do
    it 'creates CandidatePoolApplication records' do
      application_form = create(:application_form)
      stub_application_forms_in_the_pool(application_form.id)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(0).to(1)

      expect(CandidatePoolApplication.last.application_form).to eq(application_form)
    end

    it 'does not create duplicate CandidatePoolApplication records' do
      application_form = create(:application_form)
      create(:candidate_pool_application, application_form: application_form)
      stub_application_forms_in_the_pool(application_form.id)

      expect {
        described_class.new.perform
      }.not_to(change { CandidatePoolApplication.count })
    end

    it 'removes existing CandidatePoolApplication records before inserting new ones' do
      application_form = create(:application_form)
      create(:candidate_pool_application, application_form: application_form)
      stub_application_forms_in_the_pool(ApplicationForm.none)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(1).to(0)
    end

    it 'removes existing and adds new CandidatePoolApplication records' do
      existing_application_in_pool = create(:application_form)
      new_application_for_pool = create(:application_form)
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
        course_option = create(:course_option, study_mode: 'full_time')
        _application_choice = create(:application_choice, application_form: application_form, course_option: course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.study_mode_full_time).to be true
      end
    end

    context 'when the candidate has applied to a part-time course' do
      it 'sets study_mode_part_time to true' do
        application_form = create(:application_form)
        course_option = create(:course_option, study_mode: 'part_time')
        _application_choice = create(:application_choice, application_form: application_form, course_option: course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.study_mode_part_time).to be true
      end
    end

    context 'when the candidate has applied to both full-time and part-time courses' do
      it 'sets both study_mode_full_time and study_mode_part_time to true' do
        application_form = create(:application_form)
        full_time_course_option = create(:course_option, study_mode: 'full_time')
        part_time_course_option = create(:course_option, study_mode: 'part_time')
        _application_choice1 = create(:application_choice, application_form: application_form, course_option: full_time_course_option)
        _application_choice2 = create(:application_choice, application_form: application_form, course_option: part_time_course_option)
        stub_application_forms_in_the_pool(application_form.id)

        described_class.new.perform

        candidate_pool_application = CandidatePoolApplication.last
        expect(candidate_pool_application.study_mode_full_time).to be true
        expect(candidate_pool_application.study_mode_part_time).to be true
      end
    end
  end

private

  def stub_application_forms_in_the_pool(application_form_ids)
    pool_candidates_double = instance_double(Pool::Candidates, application_forms_in_the_pool: ApplicationForm.where(id: application_form_ids))
    allow(Pool::Candidates).to receive(:new).and_return(pool_candidates_double)
  end
end

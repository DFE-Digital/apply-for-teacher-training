require 'rails_helper'

RSpec.describe FindACandidate::PopulatePoolWorker do
  describe '#perform' do
    it 'creates CandidatePoolApplication records' do
      application_form = create(:application_form)

      pool_candidates_double = instance_double(Pool::Candidates, curated_application_forms: [application_form])
      allow(Pool::Candidates).to receive(:new).and_return(pool_candidates_double)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(0).to(1)

      expect(CandidatePoolApplication.last.application_form).to eq(application_form)
    end

    it 'does not create duplicate CandidatePoolApplication records' do
      application_form = create(:application_form)
      create(:candidate_pool_application, application_form: application_form)

      pool_candidates_double = instance_double(Pool::Candidates, curated_application_forms: [application_form])
      allow(Pool::Candidates).to receive(:new).and_return(pool_candidates_double)

      expect {
        described_class.new.perform
      }.not_to(change { CandidatePoolApplication.count })
    end

    it 'removes existing CandidatePoolApplication records before inserting new ones' do
      application_form = create(:application_form)
      create(:candidate_pool_application, application_form: application_form)

      pool_candidates_double = instance_double(Pool::Candidates, curated_application_forms: [])
      allow(Pool::Candidates).to receive(:new).and_return(pool_candidates_double)

      expect {
        described_class.new.perform
      }.to change { CandidatePoolApplication.count }.from(1).to(0)
    end

    it 'removes existing and adds new CandidatePoolApplication records' do
      existing_application_in_pool = create(:application_form)
      new_application_for_pool = create(:application_form)
      create(:candidate_pool_application, application_form: existing_application_in_pool)

      pool_candidates_double = instance_double(Pool::Candidates, curated_application_forms: [new_application_for_pool])
      allow(Pool::Candidates).to receive(:new).and_return(pool_candidates_double)

      expect {
        described_class.new.perform
      }.not_to(change { CandidatePoolApplication.count })

      expect(CandidatePoolApplication.last.application_form).to eq(new_application_for_pool)
    end
  end
end

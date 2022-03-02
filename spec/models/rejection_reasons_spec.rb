require 'rails_helper'

RSpec.describe RejectionReasons do
  subject(:instance) { described_class.from_config }

  describe '#reasons' do
    it 'memoizes reasons' do
      allow(YAML).to receive(:load_file).with(described_class::CONFIG_PATH).and_call_original

      instance.reasons
      instance.reasons

      expect(YAML).to have_received(:load_file).with(described_class::CONFIG_PATH).once
    end

    it 'builds top level rejection reasons' do
      expect(instance.reasons).to be_a(Array)
      expect(instance.reasons.first).to be_a(RejectionReasons::Reason)
      expect(instance.reasons.map(&:id)).to eq(%w[
        qualifications personal_statement teaching_knowledge communication_and_scheduling
        references safeguarding visa_sponsorship course_full other
      ])
    end

    it 'builds nested reasons' do
      qualifications = instance.reasons.first

      expect(qualifications.reasons).to be_a(Array)
      expect(qualifications.reasons.first).to be_a(RejectionReasons::Reason)
      expect(qualifications.reasons.map(&:id)).to eq(%w[
        no_maths_gcse no_english_gcse no_science_gcse no_degree unsuitable_degree
        unverified_qualifications qualifications_other
      ])
    end

    it 'builds details for reasons' do
      qualifications = instance.reasons.first
      qualifications_other = qualifications.reasons.last

      expect(qualifications_other).to be_a(RejectionReasons::Reason)
      expect(qualifications_other.details).to be_a(RejectionReasons::Details)

      other = instance.reasons.last

      expect(other).to be_a(RejectionReasons::Reason)
      expect(other.details).to be_a(RejectionReasons::Details)
    end
  end

  describe '#single_attribute_names' do
    it 'returns an array of all single attribute names' do
      expect(instance.single_attribute_names).to eq(%i[
        course_full
        other
        other_details
        references
        references_details
        safeguarding
        safeguarding_details
        visa_sponsorship
        visa_sponsorship_details
      ])
    end
  end

  describe '#collection_attribute_names' do
    it 'returns an array of all collection attribute names' do
      expect(instance.collection_attribute_names).to eq(%i[
        communication_and_scheduling_other
        communication_and_scheduling_reasons
        could_not_arrange_interview
        did_not_attend_interview
        did_not_reply
        no_degree
        no_english_gcse
        no_maths_gcse
        no_science_gcse
        personal_statement_other
        personal_statement_reasons
        qualifications_other
        qualifications_reasons
        quality_of_writing
        safeguarding_knowledge
        subject_knowledge
        teaching_demonstration_knowledge
        teaching_knowledge_other
        teaching_knowledge_reasons
        teaching_method_knowledge
        teaching_role_knowledge
        unsuitable_degree
        unverified_qualifications
      ])
    end
  end

  describe '#attribute_names' do
    it 'returns an array of all attribute names' do
      expect(instance.attribute_names).to eq(%i[
        communication_and_scheduling_other
        communication_and_scheduling_reasons
        could_not_arrange_interview
        course_full
        did_not_attend_interview
        did_not_reply
        no_degree
        no_english_gcse
        no_maths_gcse
        no_science_gcse
        other
        other_details
        personal_statement_other
        personal_statement_reasons
        qualifications_other
        qualifications_reasons
        quality_of_writing
        references
        references_details
        safeguarding
        safeguarding_details
        safeguarding_knowledge
        subject_knowledge
        teaching_demonstration_knowledge
        teaching_knowledge_other
        teaching_knowledge_reasons
        teaching_method_knowledge
        teaching_role_knowledge
        unsuitable_degree
        unverified_qualifications
        visa_sponsorship
        visa_sponsorship_details
      ])
    end
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::RejectionReasonsWizard do
  let(:attrs) { { current_step: 'edit' } }
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  subject(:instance) { described_class.new(store, attrs) }

  describe '.rejection_reasons' do
    it 'builds rejection reasons from configuration' do
      rejection_reasons = described_class.rejection_reasons
      expect(rejection_reasons).to be_a(RejectionReasons)
      expect(rejection_reasons.reasons.first).to be_a(RejectionReasons::Reason)
      expect(rejection_reasons.reasons.first.reasons.first).to be_a(RejectionReasons::Reason)
      expect(rejection_reasons.reasons.last.details).to be_a(RejectionReasons::Details)
    end
  end

  describe '.attribute_names' do
    it 'returns an array of all attribute names' do
      expect(described_class.attribute_names).to eq(%i[
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

  describe 'dynamic attributes' do
    it 'defines accessors for all attributes' do
      described_class.attribute_names.each do |attr_name|
        expect(instance.respond_to?(attr_name)).to be(true)
        expect(instance.respond_to?("#{attr_name}=")).to be(true)
      end
    end
  end
end

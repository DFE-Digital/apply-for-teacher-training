require 'rails_helper'

RSpec.describe RejectionReasons do
  subject(:instance) { described_class.new }

  describe 'initialize' do
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
end

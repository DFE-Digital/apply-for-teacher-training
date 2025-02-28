require 'rails_helper'

RSpec.describe Adviser::TeachingSubjectsService do
  include_context 'get into teaching api stubbed endpoints'

  subject(:teaching_subjects) { described_class.new }

  describe '#all' do
    it 'returns the primary teaching subject and secondary teaching subjects' do
      expect(teaching_subjects.all).to contain_exactly(primary_teaching_subject, preferred_teaching_subject)
    end
  end

  describe '#secondary' do
    it 'returns secondary teaching subjects' do
      expect(teaching_subjects.secondary).to contain_exactly(preferred_teaching_subject)
    end

    it 'excludes unwanted teaching subjects' do
      expect(teaching_subjects.secondary).not_to include(excluded_teaching_subject)
    end

    it 'excludes the primary teaching subject' do
      expect(teaching_subjects.secondary).not_to include(primary_teaching_subject)
    end
  end

  describe '#primary' do
    it 'returns the primary teaching subject' do
      expect(teaching_subjects.primary).to eq(primary_teaching_subject)
    end
  end
end

require 'rails_helper'

RSpec.describe GetDuplicateMatchesForApplicationForm do
  let(:candidate1) { create(:candidate) }
  let(:candidate2) { create(:candidate) }
  let!(:application_form) do
    create(:application_form, candidate: candidate1, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
  end

  context 'when another candidate has the same last name, date of birth and postcode' do
    before do
      create(:application_form, candidate: candidate2, last_name: ' thompson ', date_of_birth: Date.new(1996, 1, 1), postcode: 'w69bh')
    end

    it 'returns both candidates' do
      expect(described_class.call(application_form).pluck('candidate_id')).to contain_exactly(candidate1.id, candidate2.id)
    end
  end

  context 'when another candidate has an accented version of the last name' do
    before do
      application_form.update!(last_name: 'Gómez')
      create(:application_form, candidate: candidate2, last_name: 'Gomez', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
    end

    it 'returns both candidates' do
      expect(described_class.call(application_form).pluck('candidate_id')).to contain_exactly(candidate1.id, candidate2.id)
    end
  end

  context 'when both candidates have a blank postcode' do
    before do
      application_form.update!(postcode: nil)
      create(:application_form, candidate: candidate2, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: nil)
    end

    it 'returns both candidates' do
      expect(described_class.call(application_form).pluck('candidate_id')).to contain_exactly(candidate1.id, candidate2.id)
    end
  end

  context 'when the postcode differs' do
    before do
      create(:application_form, candidate: candidate2, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'SW1A 1AA')
    end

    it 'returns no matches' do
      expect(described_class.call(application_form)).to be_empty
    end
  end

  context 'when the only other application form belongs to the same candidate' do
    before do
      create(:application_form, candidate: candidate1, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
    end

    it 'returns no matches' do
      expect(described_class.call(application_form)).to be_empty
    end
  end
end

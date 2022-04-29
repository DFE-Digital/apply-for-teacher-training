require 'rails_helper'

RSpec.describe GetDuplicateMatches do
  let(:candidate1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, email_address: 'exemplar2@example.com') }

  describe '#call' do
    subject(:returned_array_of_hashes) { described_class.call }

    context 'matches two identical names in identical casing' do
      before do
        Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
          create(:application_form, candidate: candidate1, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now)
          create(:application_form, candidate: candidate2, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now)
        end
      end

      it 'returns an array of hashes with the correct keys' do
        expect(returned_array_of_hashes.count).to eq(2)
        expect(returned_array_of_hashes.first.keys).to \
          eq %w[candidate_id first_name last_name postcode date_of_birth email_address submitted_at]
      end

      it 'returns an array of hashes the correct values' do
        expect(returned_array_of_hashes.first['candidate_id']).to eq(candidate1.id)
        expect(returned_array_of_hashes.first['first_name']).to eq('Jeffrey')
        expect(returned_array_of_hashes.first['last_name']).to eq('Thompson')
        expect(returned_array_of_hashes.first['date_of_birth']).to eq('1998-08-08')
        expect(returned_array_of_hashes.first['postcode']).to eq('W6 9BH')
        expect(returned_array_of_hashes.first['email_address']).to eq('exemplar1@example.com')
        expect(returned_array_of_hashes.first['submitted_at'].strftime('%F')).to eq('2020-08-23')

        expect(returned_array_of_hashes.second['candidate_id']).to eq(candidate2.id)
        expect(returned_array_of_hashes.second['first_name']).to eq('Joffrey')
        expect(returned_array_of_hashes.second['last_name']).to eq('Thompson')
        expect(returned_array_of_hashes.second['date_of_birth']).to eq('1998-08-08')
        expect(returned_array_of_hashes.second['postcode']).to eq('W6 9BH')
        expect(returned_array_of_hashes.second['email_address']).to eq('exemplar2@example.com')
        expect(returned_array_of_hashes.second['submitted_at'].strftime('%F')).to eq('2020-08-23')
      end
    end

    context 'matches a capitalised name with a lowercase name' do
      let(:last_names) { returned_array_of_hashes.map { |element| element['last_name'] } }

      before do
        create(:application_form, candidate: candidate1, last_name: 'THOMPSON', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now)
        create(:application_form, candidate: candidate2, last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now)
      end

      it 'returns an array of hashes with the correct keys' do
        expect(returned_array_of_hashes.count).to eq(2)
      end

      it 'returns all duplicates' do
        expect(last_names).to include('THOMPSON')
        expect(last_names).to include('Thompson')
      end
    end

    context 'matches a postcode with or without a space' do
      let(:postcodes) { returned_array_of_hashes.map { |element| element['postcode'] } }

      before do
        create(:application_form, candidate: candidate1, last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now)
        create(:application_form, candidate: candidate2, last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w69bh ', submitted_at: Time.zone.now)
      end

      it 'returns an array of hashes with the correct keys' do
        expect(returned_array_of_hashes.count).to eq(2)
      end

      it 'returns all duplicates' do
        expect(postcodes).to include('W6 9BH')
        expect(postcodes).to include('W69BH')
      end
    end

    context 'when duplicated unsubmitted applications' do
      let(:candidate_ids) { returned_array_of_hashes.map { |element| element['candidate_id'] } }

      before do
        Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
          create(:application_form, candidate: candidate1, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: nil)
          create(:application_form, candidate: candidate2, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: nil)
        end
      end

      it 'returns all duplicates' do
        expect(candidate_ids).to include(candidate1.id, candidate2.id)
      end
    end

    context 'when duplicated applications are both international' do
      let(:candidate_ids) { returned_array_of_hashes.map { |element| element['candidate_id'] } }

      before do
        Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
          create(:application_form, candidate: candidate1, first_name: 'Calina', last_name: 'Rosario', date_of_birth: '1998-08-08', address_type: 'international')
          create(:application_form, candidate: candidate2, first_name: 'Calona', last_name: 'Rosario', date_of_birth: '1998-08-08', address_type: 'international')
        end
      end

      it 'matches, returning all duplicates' do
        expect(candidate_ids).to include(candidate1.id, candidate2.id)
      end
    end

    context 'when duplicated applications, one UK and one international with no postcodes' do
      let(:candidate_ids) { returned_array_of_hashes.map { |element| element['candidate_id'] } }

      before do
        Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
          create(:application_form, candidate: candidate1, first_name: 'Calina', last_name: 'Rosario', date_of_birth: '1998-08-08', address_type: 'uk')
          create(:application_form, candidate: candidate2, first_name: 'Calona', last_name: 'Rosario', date_of_birth: '1998-08-08', address_type: 'international')
        end
      end

      it 'matches, returning all duplicates' do
        expect(candidate_ids).to include(candidate1.id, candidate2.id)
      end
    end

    context 'when two non duplicated applications one uk with postcode and one international with no postcode' do
      let(:candidate_ids) { returned_array_of_hashes.map { |element| element['candidate_id'] } }

      before do
        Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
          create(:application_form, candidate: candidate1, first_name: 'Calina', last_name: 'Rosario', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', address_type: 'uk')
          create(:application_form, candidate: candidate2, first_name: 'Calona', last_name: 'Rosario', date_of_birth: '1998-08-08', address_type: 'international')
        end
      end

      it 'does not match' do
        expect(candidate_ids).not_to include(candidate1.id, candidate2.id)
      end
    end

    context 'when two duplicated applications one with a null postcode and one with an empty string' do
      let(:candidate_ids) { returned_array_of_hashes.map { |element| element['candidate_id'] } }

      before do
        Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
          create(:application_form, candidate: candidate1, first_name: 'Calina', last_name: 'Rosario', date_of_birth: '1998-08-08', postcode: ' ')
          create(:application_form, candidate: candidate2, first_name: 'Calona', last_name: 'Rosario', date_of_birth: '1998-08-08', postcode: nil)
        end
      end

      it 'returns all duplicates' do
        expect(candidate_ids).to include(candidate1.id, candidate2.id)
      end
    end
  end
end

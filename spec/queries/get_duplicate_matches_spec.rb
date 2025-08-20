require 'rails_helper'

RSpec.describe GetDuplicateMatches do
  let(:candidate_1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate_2) { create(:candidate, email_address: 'exemplar2@example.com') }

  describe '#call' do
    subject(:returned_array_of_hashes) { described_class.call }

    let(:candidate_ids) { returned_array_of_hashes.map { |element| element['candidate_id'] } }

    context 'matches two identical names in identical casing' do
      before do
        application_form(candidate_1, first_name: 'Jeffrey', submitted_at: Time.zone.local(2020, 8, 23, 12))
        application_form(candidate_2, first_name: 'Joffrey', submitted_at: Time.zone.local(2020, 8, 23, 12))
      end

      it 'returns an array of hashes with the correct keys' do
        expect(returned_array_of_hashes.count).to eq(2)
        expect(returned_array_of_hashes.first.keys).to \
          eq %w[candidate_id first_name last_name postcode date_of_birth email_address submitted_at]
      end

      it 'returns an array of hashes the correct values' do
        expect(returned_array_of_hashes.first['candidate_id']).to eq(candidate_1.id)
        expect(returned_array_of_hashes.first['first_name']).to eq('Jeffrey')
        expect(returned_array_of_hashes.first['last_name']).to eq('Thompson')
        expect(returned_array_of_hashes.first['date_of_birth']).to eq('1998-08-08')
        expect(returned_array_of_hashes.first['postcode']).to eq('W6 9BH')
        expect(returned_array_of_hashes.first['email_address']).to eq('exemplar1@example.com')
        expect(returned_array_of_hashes.first['submitted_at'].strftime('%F')).to eq('2020-08-23')

        expect(returned_array_of_hashes.second['candidate_id']).to eq(candidate_2.id)
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
        application_form(candidate_1, last_name: 'THOMPSON')
        application_form(candidate_2, last_name: 'Thompson')
      end

      it 'returns an array of hashes with the correct keys' do
        expect(returned_array_of_hashes.count).to eq(2)
      end

      it 'returns all duplicates' do
        expect(last_names).to include('THOMPSON')
        expect(last_names).to include('Thompson')
      end
    end

    context 'matches a name using an accent' do
      let(:last_names) { returned_array_of_hashes.map { |element| element['last_name'] } }

      before do
        application_form(candidate_1, last_name: 'Fernández')
        application_form(candidate_2, last_name: 'Fernandez')
      end

      it 'returns an array of hashes with the correct keys' do
        expect(returned_array_of_hashes.count).to eq(2)
      end

      it 'returns all duplicates' do
        expect(last_names).to include('Fernández')
        expect(last_names).to include('Fernandez')
      end
    end

    context 'matches a postcode with or without a space' do
      let(:postcodes) { returned_array_of_hashes.map { |element| element['postcode'] } }

      before do
        application_form(candidate_1, postcode: 'w6 9bh')
        application_form(candidate_2, postcode: 'w69bh')
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
      before do
        application_form(candidate_1, submitted_at: nil)
        application_form(candidate_2, submitted_at: nil)
      end

      it 'returns all duplicates' do
        expect(candidate_ids).to contain_exactly(candidate_1.id, candidate_2.id)
      end
    end

    context 'when duplicated applications are both international' do
      before do
        application_form(candidate_1, address_type: 'international')
        application_form(candidate_2, address_type: 'international')
      end

      it 'matches, returning all duplicates' do
        expect(candidate_ids).to contain_exactly(candidate_1.id, candidate_2.id)
      end
    end

    context 'when duplicated applications, one UK and one international with no postcodes' do
      before do
        application_form(candidate_1, address_type: 'uk')
        application_form(candidate_2, address_type: 'international')
      end

      it 'matches, returning all duplicates' do
        expect(candidate_ids).to contain_exactly(candidate_1.id, candidate_2.id)
      end
    end

    context 'when two non duplicated applications one uk with postcode and one international with no postcode' do
      before do
        application_form(candidate_1, postcode: 'SA1 1AA', address_type: 'uk')
        application_form(candidate_2, postcode: nil, address_type: 'international')
      end

      it 'does not match' do
        expect(candidate_ids).not_to include(candidate_1.id, candidate_2.id)
      end
    end

    context 'when two duplicated applications one with a null postcode and one with an empty string' do
      before do
        application_form(candidate_1, postcode: ' ')
        application_form(candidate_2, postcode: nil)
      end

      it 'returns all duplicates' do
        expect(candidate_ids).to contain_exactly(candidate_1.id, candidate_2.id)
      end
    end

    context "when there's two applications which match, but one is the carry-over of the other" do
      before do
        form_1 = application_form(candidate_1)
        application_form(candidate_1, previous_application_form: form_1)
      end

      it 'does not match' do
        expect(candidate_ids).not_to include(candidate_1.id)
      end
    end

    context 'when there are duplicates, but one has a third application as its previous application' do
      before do
        form_1 = application_form(candidate_1)
        application_form(candidate_1, previous_application_form: form_1)

        application_form(candidate_2)
      end

      it 'returns all duplicates' do
        expect(candidate_ids).to contain_exactly(candidate_1.id, candidate_2.id)
      end
    end

    context 'when there are duplicates, but both have previous applications' do
      before do
        carry_over_form = application_form(candidate_1, phase: 'apply_1', submitted_at: 1.year.ago)
        application_form(candidate_1, previous_application_form: carry_over_form, phase: 'apply_1')

        previous_form = application_form(candidate_2, phase: 'apply_1', submitted_at: 1.year.ago)
        application_form(candidate_2, previous_application_form: previous_form, phase: 'apply_1')
      end

      it 'returns all duplicates' do
        expect(candidate_ids).to contain_exactly(candidate_1.id, candidate_2.id)
      end
    end

    def application_form(candidate, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh', submitted_at: Time.zone.now, **attributes)
      create(:application_form, candidate:, first_name:, last_name:, date_of_birth:, postcode:, submitted_at:, **attributes)
    end
  end
end

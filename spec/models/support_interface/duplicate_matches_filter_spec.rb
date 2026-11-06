require 'rails_helper'

RSpec.describe SupportInterface::DuplicateMatchesFilter do
  let(:last_name) { Faker::Name.last_name }
  let(:date_of_birth) { '01/01/1990' }
  let(:postcode) { 'SW1A 1AA' }
  let(:candidate_1) { create(:candidate) }
  let(:application_form_1) { create(:application_form, candidate: candidate_1, last_name:, date_of_birth:, postcode:) }
  let(:candidate_2) { create(:candidate) }
  let(:application_form_2) { create(:application_form, candidate: candidate_2, last_name:, date_of_birth:, postcode:) }
  let(:duplicate_match) { create(:duplicate_match, candidates: [candidate_1, candidate_2], postcode:, date_of_birth:, last_name:) }
  let(:params) { {} }

  describe '#filter' do
    context 'when no filters are applied' do
      it 'returns all filters with no values' do
        filter = described_class.new(params:)

        expect(filter.filters).to eq(
          [
            {
              type: :search,
              heading: 'Name',
              value: nil,
              name: 'name',
            },
            {
              type: :search,
              heading: 'Email',
              value: nil,
              name: 'email',
            },
            {
              type: :search,
              heading: 'Postcode',
              value: nil,
              name: 'postcode',
            },
            {
              type: :date,
              heading: 'Date of birth',
              value: {
                '3i' => nil,
                '2i' => nil,
                '1i' => nil,
              },
              name: 'date_of_birth',
            },
          ]
        )
      end
    end

    context 'when a name filter is applied' do
      it 'returns the name filter with the applied value' do
        filter = described_class.new(params: params.merge(name: 'John Doe'))

        expect(filter.filters.find { |f| f[:name] == 'name' }).to eq(
          {
            type: :search,
            heading: 'Name',
            value: 'John Doe',
            name: 'name',
          }
        )
      end
    end

    context 'when an email filter is applied' do
      it 'returns the email filter with the applied value' do
        filter = described_class.new(params: params.merge(email: 'john.doe@example.com'))

        expect(filter.filters.find { |f| f[:name] == 'email' }).to eq(
          {
            type: :search,
            heading: 'Email',
            value: 'john.doe@example.com',
            name: 'email',
          }
        )
      end
    end

    context 'when a postcode filter is applied' do
      it 'returns the postcode filter with the applied value' do
        filter = described_class.new(params: params.merge(postcode: 'SW1A 1AA'))

        expect(filter.filters.find { |f| f[:name] == 'postcode' }).to eq(
          {
            type: :search,
            heading: 'Postcode',
            value: 'SW1A 1AA',
            name: 'postcode',
          }
        )
      end
    end

    context 'when a date of birth filter is applied' do
      it 'returns the date of birth filter with the applied value' do
        filter = described_class.new(params: params.merge('date_of_birth(3i)' => '01', 'date_of_birth(2i)' => '01', 'date_of_birth(1i)' => '2000'))

        expect(filter.filters.find { |f| f[:name] == 'date_of_birth' }).to eq(
          {
            type: :date,
            heading: 'Date of birth',
            value: { '3i' => '01', '2i' => '01', '1i' => '2000' },
            name: 'date_of_birth',
          }
        )
      end
    end
  end

  describe '#filter_records' do
    before do
      3.times do
        cand_1 = create(:candidate)
        create(:application_form, candidate: cand_1)
        cand_2 = create(:candidate)
        create(:application_form, candidate: cand_2)
        create(:duplicate_match, candidates: [cand_1, cand_2])
      end
      application_form_1
      application_form_2
      duplicate_match
    end

    context 'when no filters are applied' do
      it 'returns all duplicate matches' do
        filter = described_class.new(params:)

        expect(filter.filter_records(DuplicateMatch.all)).to match_array(DuplicateMatch.all)
      end
    end

    context 'when a name filter is applied' do
      it 'returns only duplicate matches with the specified name' do
        filter = described_class.new(params: params.merge(name: last_name))

        expect(filter.filter_records(DuplicateMatch.all)).to match_array([duplicate_match])
      end
    end

    context 'when an email filter is applied' do
      it 'returns only duplicate matches with the specified email' do
        filter = described_class.new(params: params.merge(email: candidate_1.email_address))

        expect(filter.filter_records(DuplicateMatch.all)).to match_array([duplicate_match])
      end
    end

    context 'when a postcode filter is applied' do
      it 'returns only duplicate matches with the specified postcode' do
        filter = described_class.new(params: params.merge(postcode:))

        expect(filter.filter_records(DuplicateMatch.all)).to match_array([duplicate_match])
      end
    end

    context 'when a date of birth filter is applied' do
      it 'returns only duplicate matches with the specified date of birth' do
        filter = described_class.new(params: params.merge('date_of_birth(3i)' => duplicate_match.date_of_birth.day.to_s, 'date_of_birth(2i)' => duplicate_match.date_of_birth.month.to_s, 'date_of_birth(1i)' => duplicate_match.date_of_birth.year.to_s))

        expect(filter.filter_records(DuplicateMatch.all)).to match_array([duplicate_match])
      end
    end
  end
end

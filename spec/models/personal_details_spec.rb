require 'rails_helper'

describe PersonalDetails, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_length_of(:title).is_at_most(4) }

  it { is_expected.to validate_presence_of :first_name }
  it { is_expected.to validate_presence_of :last_name }
  it { is_expected.to validate_presence_of :date_of_birth }

  it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
  it { is_expected.to validate_length_of(:preferred_name).is_at_most(50) }

  describe 'date of birth' do
    let(:personal_details) { described_class.new(date_of_birth: date_of_birth) }

    context 'when date is before year 1900' do
      let(:date_of_birth) { '31-12-1899' }

      it 'provides a too_old validation error' do
        personal_details.save

        date_of_birth_error = personal_details.errors.details[:date_of_birth].first[:error]

        expect(date_of_birth_error).to be :too_old
      end
    end

    context 'when date is after year 1900' do
      let(:date_of_birth) { '1-1-1900' }

      it 'does NOT provide a too_old validation error' do
        personal_details.save

        expect(personal_details.errors.details[:date_of_birth]).to be_empty
      end
    end
  end
end

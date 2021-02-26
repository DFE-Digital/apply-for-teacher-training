RSpec.shared_examples 'date_of_birth validations' do |verify_presence|
  let(:day) { date_of_birth.day }
  let(:month) { date_of_birth.month }
  let(:year) { date_of_birth.year }

  describe 'when date is in the future' do
    let(:date_of_birth) { 50.years.from_now }

    it 'returns :dob_future error' do
      expect(model).to be_invalid
      expect(model.errors[:date_of_birth]).to contain_exactly(I18n.t('errors.messages.dob_future', article: 'a', attribute: 'date of birth'))
    end
  end

  describe 'when date is below the minimum age' do
    let(:date_of_birth) { Time.zone.today - 14.years }

    it 'returns :dob_below_min_age error' do
      age_limit = Time.zone.today - 16.years

      expect(model).to be_invalid
      expect(model.errors[:date_of_birth]).to contain_exactly(
        I18n.t('errors.messages.dob_below_min_age', date: age_limit.to_s(:govuk_date), min_age: 16),
      )
    end
  end

  describe 'when date is not present', if: verify_presence do
    let(:date_of_birth) { Struct.new(:day, :month, :year).new(nil, nil, nil) }

    it 'returns :blank_date error' do
      expect(model).to be_invalid
      expect(model.errors[:date_of_birth]).to contain_exactly(
        I18n.t('errors.messages.blank_date', article: 'a', attribute: 'date of birth'),
      )
    end
  end
end

require 'rails_helper'

RSpec.describe ValidationUtils do
  describe '#valid_year' do
    let(:form) do
      Class.new do
        include ValidationUtils
      end
    end

    it 'expect 1900 to be valid year' do
      correct_year = 1990

      expect(form.new).to be_valid_year(correct_year)
    end

    it 'expect 3000 not to be a valid year' do
      too_big_year = 3000

      expect(form.new).not_to be_valid_year(too_big_year)
    end

    it 'expect 22000 not to be a valid year' do
      too_long_year = 12345

      expect(form.new).not_to be_valid_year(too_long_year)
    end
  end

  describe '#future_year' do
    let(:form) do
      Class.new do
        include ValidationUtils
      end
    end

    it 'returns true if the year passed is greater than the current year' do
      next_year = Time.zone.today.year.to_i + 1

      expect(form.new.future_year?(next_year)).to eq true
    end

    it 'returns false if the year passed is before or equal to the current year' do
      last_year = Time.zone.today.year.to_i

      expect(form.new.future_year?(last_year)).to eq false
    end
  end
end

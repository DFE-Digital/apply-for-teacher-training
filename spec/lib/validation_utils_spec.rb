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
end

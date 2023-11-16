require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::MonthlyStatisticsReport do
  describe 'validations' do
    it { is_expected.to validate_presence_of :statistics }
    it { is_expected.to validate_presence_of :generation_date }
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :month }
  end
end

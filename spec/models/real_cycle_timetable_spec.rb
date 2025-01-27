require 'rails_helper'

RSpec.describe RealCycleTimetable do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:recruitment_cycle_year) }
  end
end

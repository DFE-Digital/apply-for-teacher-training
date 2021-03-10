require 'rails_helper'

RSpec.describe Interview, type: :model do
  subject(:interview) { Interview.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:application_choice) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:date_and_time) }
  end
end

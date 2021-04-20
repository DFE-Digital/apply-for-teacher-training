require 'rails_helper'
RSpec.describe OfferValidations, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:course_option) }
  end
end

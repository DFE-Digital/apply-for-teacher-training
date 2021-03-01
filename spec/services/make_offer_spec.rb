require 'rails_helper'

RSpec.describe MakeOffer do
  include CourseOptionHelpers

  let(:make_offer) do
    MakeOffer.new(actor: provider_user,
                  application_choice: application_choice,
                  course_option: course_option,
                  conditions: conditions)
  end

  describe '#save!' do
    let(:application_choice) { create(:application_choice) }
    let(:course_option) { course_option_for_provider(provider: application_choice.course_option.provider) }
    let(:provider_user) { create(:provider_user, providers: [build(:provider)]) }
    let(:conditions) { [ Faker::Lorem.sentence ] }

    it 'throws an exception if the actor is not authorised to perform this action' do
      expect {
        make_offer.save!
      }.to raise_error(ProviderAuthorisation::NotAuthorisedError, 'You are not allowed to make decisions')
    end
  end
end

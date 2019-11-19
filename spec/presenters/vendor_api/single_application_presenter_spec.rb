require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  describe '#candidate' do
    it 'returns nationality in the correct format' do
      application_form = create(:completed_application_form) do |form|
        form.first_nationality = 'British'
        form.second_nationality = 'American'
      end
      application_choice = create(:application_choice, application_form: application_form)
      single_application_presenter = VendorApi::SingleApplicationPresenter.new(application_choice)

      expect(single_application_presenter.as_json[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end
  end
end

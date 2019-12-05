require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  let(:application_form) do
    create(:completed_application_form) do |form|
      form.first_nationality = 'British'
      form.second_nationality = 'American'
    end
  end
  let(:application_choice) do
    create(:application_choice, application_form: application_form)
  end

  describe '#candidate' do
    it 'returns nationality in the correct format' do
      single_application_presenter = VendorApi::SingleApplicationPresenter.new(application_choice)

      expect(single_application_presenter.as_json[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end
  end

  describe '#as_json' do
    context 'given a relation that includes application_qualifications' do
      let(:given_relation) { GetApplicationChoicesForProvider.call(provider: application_choice.provider) }
      let!(:presenter) { VendorApi::SingleApplicationPresenter.new(given_relation.first) }

      it 'does not trigger any additional queries' do
        expect { presenter.as_json }.not_to make_database_queries
      end
    end
  end
end

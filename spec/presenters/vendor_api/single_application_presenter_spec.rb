require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  let(:application_form) do
    create(:completed_application_form) do |form|
      form.first_nationality = 'British'
      form.second_nationality = 'American'
    end
  end

  let(:application_choice) do
    create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)
  end

  let(:single_application_presenter) do
    VendorApi::SingleApplicationPresenter.new(application_choice)
  end

  describe '#candidate' do
    it 'returns nationality in the correct format' do
      json_data = single_application_presenter.as_json
      expect(json_data.dig(:attributes, :candidate, :nationality)).to eq(%w[GB US])
    end
  end

  describe '#hesa_itt_data' do
    it 'is hidden by default' do
      json_data = single_application_presenter.as_json
      expect(json_data.dig(:attributes, :hesa_itt_data)).to be_nil
    end

    it 'becomes available once application status is \'enrolled\'' do
      application_choice.update_attributes(status: 'enrolled')
      data = single_application_presenter.as_json.dig(:attributes, :hesa_itt_data)
      expect(data).not_to be_nil
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

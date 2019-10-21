require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  subject(:presenter) { described_class.new(application_choice) }

  let(:application_choice) { create :application_choice }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '#as_json' do
    let(:json) { presenter.as_json.deep_symbolize_keys }
    let(:expected_course_attributes) do
      {
        start_date: Time.now,
        provider_ucas_code: application_choice.provider.code,
        site_ucas_code: application_choice.course_option.site.code,
        course_ucas_code: application_choice.course.code,
      }
    end
    let(:expected_candidate_attributes) do
      {
        first_name: application_choice.application_form.first_name,
        last_name: application_choice.application_form.last_name,
        date_of_birth: application_choice.application_form.date_of_birth,
        nationality: %w[NL],
        uk_residency_status: '',
      }
    end

    it 'returns correct course attributes' do
      expect(json.dig(:attributes, :course)).to eq expected_course_attributes
    end

    it 'returns correct candidate attributes' do
      expect(json.dig(:attributes, :candidate)).to eq expected_candidate_attributes
    end
  end
end

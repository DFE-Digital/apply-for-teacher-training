require 'rails_helper'
RSpec.describe VendorAPI::ApplicationDataConcerns do
  subject(:application_data_concerns) { ::TestApplicationDataConcerns.new(provider, api_version: version) }

  let(:provider) { build(:provider) }

  let(:include_properties) do
    [
      :notes,
      offer: %i[conditions],
      application_form: %i[candidate application_qualifications application_references application_work_experiences application_work_history_breaks application_volunteering_experiences english_proficiency],
      course_option: [{ course: %i[provider] }, :site],
      current_course_option: [{ course: %i[provider] }, :site],
      interviews: %i[provider],
    ]
  end

  describe '#application_choices_visible_to_provider' do
    before do
      allow(GetApplicationChoicesForProviders).to receive(:call)
    end

    context 'when version is v1' do
      let(:version) { 'v1' }

      it 'excludes deferrals' do
        application_data_concerns.send(:application_choices_visible_to_provider)

        expect(GetApplicationChoicesForProviders)
          .to have_received(:call).with(providers: [provider], exclude_deferrals: true, includes: include_properties)
      end
    end

    context 'when version is v1.0' do
      let(:version) { 'v1.0' }

      it 'excludes deferrals' do
        application_data_concerns.send(:application_choices_visible_to_provider)

        expect(GetApplicationChoicesForProviders)
          .to have_received(:call).with(providers: [provider], exclude_deferrals: true, includes: include_properties)
      end
    end

    context 'when version is v1.1' do
      let(:version) { 'v1.1' }

      it 'does not excludes deferrals' do
        application_data_concerns.send(:application_choices_visible_to_provider)

        expect(GetApplicationChoicesForProviders)
          .to have_received(:call).with(providers: [provider], exclude_deferrals: false, includes: include_properties)
      end
    end
  end
end

class TestApplicationDataConcerns
  include VendorAPI::ApplicationDataConcerns
  include Versioning

  attr_reader :current_provider, :params

  def initialize(provider, params)
    @current_provider = provider
    @params = params
  end
end

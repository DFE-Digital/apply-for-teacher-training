require 'rails_helper'

RSpec.describe DataMigrations::Remove2027InternationalQualificationsFlowFeatureFlag do
  before do
    create(:feature, name: '2027_international_qualifications_flow') if Feature.find_by(name: '2027_international_qualifications_flow').blank?
    if Feature.find_by(name: '2027_application_form_contact_details_residency_questions').blank?
      create(:feature, name: '2027_application_form_contact_details_residency_questions')
    end
    create(:feature, name: 'foo')
  end

  context 'when the feature flag exists' do
    it 'removes the relevant feature flag' do
      expect { described_class.new.change }.to change { Feature.count }.by(-2)
      expect(Feature.where(name: '2027_international_qualifications_flow')).to be_none
      expect(Feature.where(name: '2027_application_form_contact_details_residency_questions')).to be_none
      expect(Feature.where(name: 'foo')).to be_present
    end
  end

  context 'when the feature flags have already been dropped' do
    before do
      Feature.find_by(name: '2027_international_qualifications_flow')&.destroy if Feature.find_by(name: '2027_international_qualifications_flow').present?
      if Feature.find_by(name: '2027_application_form_contact_details_residency_questions').present?
        Feature.find_by(name: '2027_application_form_contact_details_residency_questions')&.destroy
      end
    end

    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end

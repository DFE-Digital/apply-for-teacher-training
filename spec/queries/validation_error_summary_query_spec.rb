require 'rails_helper'

RSpec.describe ValidationErrorSummaryQuery do
  let(:service_name) { :apply }

  describe '#call' do
    it 'returns an empty result' do
      expect(described_class.new(service_name).call).to eq([])
    end

    it 'returns data for each time period' do
      create :validation_error, created_at: 2.days.ago
      create :validation_error, created_at: 10.days.ago
      old_error = create :validation_error, created_at: 60.days.ago
      create :validation_error, created_at: 60.days.ago, user: old_error.user

      expect(described_class.new(service_name).call).to eq([
        {
          'attribute' => 'feedback',
          'form_object' => 'RefereeInterface::ReferenceFeedbackForm',
          'incidents_all_time' => 4,
          'incidents_last_month' => 2,
          'incidents_last_week' => 1,
          'unique_users_all_time' => 3,
          'unique_users_last_month' => 2,
          'unique_users_last_week' => 1,
        },
      ])
    end
  end

  describe 'sorting' do
    it "returns results sorted by 'All time'" do
      create :validation_error, form_object: 'Foo', created_at: 2.days.ago
      create :validation_error, form_object: 'Bar', created_at: 6.days.ago
      create :validation_error, form_object: 'Baz', created_at: 50.days.ago
      create :validation_error, form_object: 'Baz', created_at: 60.days.ago

      expect(described_class.new(service_name, described_class::ALL_TIME).call).to eq([
        {
          'form_object' => 'Baz',
          'attribute' => 'feedback',
          'incidents_last_week' => 0,
          'unique_users_last_week' => 0,
          'incidents_last_month' => 0,
          'unique_users_last_month' => 0,
          'incidents_all_time' => 2,
          'unique_users_all_time' => 2,
        },
        {
          'form_object' => 'Bar',
          'attribute' => 'feedback',
          'incidents_last_week' => 1,
          'unique_users_last_week' => 1,
          'incidents_last_month' => 1,
          'unique_users_last_month' => 1,
          'incidents_all_time' => 1,
          'unique_users_all_time' => 1,
        },
        {
          'form_object' => 'Foo',
          'attribute' => 'feedback',
          'incidents_last_week' => 1,
          'unique_users_last_week' => 1,
          'incidents_last_month' => 1,
          'unique_users_last_month' => 1,
          'incidents_all_time' => 1,
          'unique_users_all_time' => 1,
        },
      ])
    end

    it "returns results sorted by 'Last week'" do
      create :validation_error, form_object: 'Foo', created_at: 2.days.ago
      create :validation_error, form_object: 'Bar', created_at: 6.days.ago
      create :validation_error, form_object: 'Foo', created_at: 10.days.ago

      expect(described_class.new(service_name, described_class::LAST_WEEK).call).to eq([
        {
          'form_object' => 'Bar',
          'attribute' => 'feedback',
          'incidents_last_week' => 1,
          'unique_users_last_week' => 1,
          'incidents_last_month' => 1,
          'unique_users_last_month' => 1,
          'incidents_all_time' => 1,
          'unique_users_all_time' => 1,
        },
        {
          'form_object' => 'Foo',
          'attribute' => 'feedback',
          'incidents_last_week' => 1,
          'unique_users_last_week' => 1,
          'incidents_last_month' => 2,
          'unique_users_last_month' => 2,
          'incidents_all_time' => 2,
          'unique_users_all_time' => 2,
        },
      ])
    end

    it "returns resulted sorted by 'Last month'" do
      create :validation_error, form_object: 'Foo', created_at: 2.days.ago
      create :validation_error, form_object: 'Bar', created_at: 6.days.ago
      create :validation_error, form_object: 'Foo', created_at: 10.days.ago

      expect(described_class.new(service_name, described_class::LAST_MONTH).call).to eq([
        {
          'form_object' => 'Foo',
          'attribute' => 'feedback',
          'incidents_last_week' => 1,
          'unique_users_last_week' => 1,
          'incidents_last_month' => 2,
          'unique_users_last_month' => 2,
          'incidents_all_time' => 2,
          'unique_users_all_time' => 2,
        },
        {
          'form_object' => 'Bar',
          'attribute' => 'feedback',
          'incidents_last_week' => 1,
          'unique_users_last_week' => 1,
          'incidents_last_month' => 1,
          'unique_users_last_month' => 1,
          'incidents_all_time' => 1,
          'unique_users_all_time' => 1,
        },
      ])
    end
  end

  context 'when scoped to manage errors' do
    let(:service_name) { :manage }

    it 'only returns data about errors from manage' do
      create :validation_error, form_object: 'CandidateForm', created_at: 1.day.ago
      create :validation_error, form_object: 'OtherCandidateForm', created_at: 3.days.ago
      create :validation_error, service: 'manage', form_object: 'ProviderForm', created_at: 1.day.ago
      create :validation_error, service: 'manage', form_object: 'OtherProviderForm', created_at: 2.days.ago

      expect(described_class.new(service_name).call).to eq([
        {
          'attribute' => 'feedback',
          'form_object' => 'OtherProviderForm',
          'incidents_all_time' => 1,
          'incidents_last_month' => 1,
          'incidents_last_week' => 1,
          'unique_users_all_time' => 1,
          'unique_users_last_month' => 1,
          'unique_users_last_week' => 1,
        },
        {
          'attribute' => 'feedback',
          'form_object' => 'ProviderForm',
          'incidents_all_time' => 1,
          'incidents_last_month' => 1,
          'incidents_last_week' => 1,
          'unique_users_all_time' => 1,
          'unique_users_last_month' => 1,
          'unique_users_last_week' => 1,
        },
      ])
    end
  end
end

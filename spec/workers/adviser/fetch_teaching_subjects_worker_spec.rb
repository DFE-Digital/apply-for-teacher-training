require 'rails_helper'

RSpec.describe Adviser::FetchTeachingSubjectsWorker do
  before do
    FeatureFlag.activate(:adviser_sign_up)
  end

  describe '#perform' do
    it 'creates new Adviser::TeachingSubject records' do
      teaching_subject_from_api = GetIntoTeachingApiClient::TeachingSubject.new(
        id: 'some-id',
        value: 'Maths',
      )

      stub_get_teaching_subjects(teaching_subject_from_api)

      expect {
        described_class.new.perform
      }.to change(Adviser::TeachingSubject, :count).from(0).to(1)

      expect(Adviser::TeachingSubject.last).to have_attributes(
        external_identifier: 'some-id',
        title: 'Maths',
        level: 'secondary',
      )
    end

    it 'creates new Primary Adviser::TeachingSubject' do
      primary_subject_id_from_constants = Adviser::Constants.fetch(:teaching_subjects, :primary)
      primary_teaching_subject_from_api = GetIntoTeachingApiClient::TeachingSubject.new(
        id: primary_subject_id_from_constants,
        value: 'Primary (Maths)',
      )

      stub_get_teaching_subjects(primary_teaching_subject_from_api)

      expect {
        described_class.new.perform
      }.to change(Adviser::TeachingSubject, :count).from(0).to(1)

      expect(Adviser::TeachingSubject.last).to have_attributes(
        external_identifier: primary_subject_id_from_constants,
        title: 'Primary (Maths)',
        level: 'primary',
      )
    end

    it 'does not create any Adviser::TeachingSubjects marked as excluded' do
      excluded_subject_id_from_constants = Adviser::Constants.fetch(:teaching_subjects, :excluded).values.first
      excluded_teaching_subject_from_api = GetIntoTeachingApiClient::TeachingSubject.new(
        id: excluded_subject_id_from_constants,
        value: 'Excluded Subject',
      )

      stub_get_teaching_subjects(excluded_teaching_subject_from_api)

      expect {
        described_class.new.perform
      }.not_to change(Adviser::TeachingSubject, :count)
    end

    context 'when matching Adviser::TeachingSubjects exist' do
      it 'does not create any Teaching Subjects' do
        teaching_subject_from_api = GetIntoTeachingApiClient::TeachingSubject.new(
          id: 'some-id',
          value: 'Maths',
        )

        stub_get_teaching_subjects(teaching_subject_from_api)

        create(:adviser_teaching_subject, external_identifier: 'some-id')

        expect {
          described_class.new.perform
        }.not_to change(Adviser::TeachingSubject, :count)
      end

      it 'updates the title' do
        teaching_subject_from_api = GetIntoTeachingApiClient::TeachingSubject.new(
          id: 'some-id',
          value: 'New Title',
        )

        stub_get_teaching_subjects(teaching_subject_from_api)

        create(:adviser_teaching_subject, title: 'Old Title', external_identifier: 'some-id')

        described_class.new.perform

        expect(Adviser::TeachingSubject.last.title).to eq('New Title')
      end
    end

    context 'when Adviser::TeachingSubject is no longer on the API' do
      it 'marks the Adviser::TeachingSubject as discarded' do
        stub_get_teaching_subjects

        create(:adviser_teaching_subject, external_identifier: 'some-id')

        described_class.new.perform

        expect(Adviser::TeachingSubject.last).to be_discarded
      end
    end

    context 'when the adviser_sign_up feature is disabled' do
      before do
        FeatureFlag.deactivate(:adviser_sign_up)
      end

      it 'does not create any Teaching Subjects' do
        teaching_subject_from_api = GetIntoTeachingApiClient::TeachingSubject.new(
          id: 'some-id',
          value: 'Maths',
        )

        stub_get_teaching_subjects(teaching_subject_from_api)

        expect {
          described_class.new.perform
        }.not_to change(Adviser::TeachingSubject, :count)
      end
    end
  end

private

  def stub_get_teaching_subjects(teaching_subjects = [])
    get_teaching_subjects = Array.wrap(teaching_subjects)
    lookup_items_api_double = instance_double(GetIntoTeachingApiClient::LookupItemsApi,
                                              get_teaching_subjects: get_teaching_subjects)
    allow(GetIntoTeachingApiClient::LookupItemsApi).to receive(:new).and_return(lookup_items_api_double)
  end
end

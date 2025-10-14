require 'rails_helper'

RSpec.describe CandidateInterface::PublishDuplicatePreferences do
  describe '#call' do
    it 'publishes duplicate preference' do
      application_form = create(
        :application_form,
        :completed,
        submitted_application_choices_count: 1,
      )
      _published_preference = create(
        :candidate_preference,
        updated_at: 2.days.ago,
        application_form:,
      )
      another_duplicated_preference = create(
        :candidate_preference,
        :duplicated,
        application_form:,
      )
      duplicated_preference = create(
        :candidate_preference,
        :duplicated,
        application_form:,
      )
      another_application_form = create(
        :application_form,
        :completed,
        submitted_application_choices_count: 1,
      )
      existing_preference = create(
        :candidate_preference,
        updated_at: 2.days.from_now,
        application_form: another_application_form,
      )

      expect {
        described_class.new.call
      }.to change { duplicated_preference.reload.status }
        .from('duplicated').to('published')
      expect(existing_preference.reload).to eq(existing_preference)

      expect(CandidatePreference.where(id: another_duplicated_preference.id))
        .not_to exist
    end

    context 'when published preference has been updated after duplicated one' do
      it 'does not publish duplicate preference' do
        application_form = create(
          :application_form,
          :completed,
          submitted_application_choices_count: 1,
        )
        _published_preference = create(
          :candidate_preference,
          application_form:,
        )
        duplicated_preference = create(
          :candidate_preference,
          :duplicated,
          updated_at: 2.days.ago,
          application_form:,
        )

        expect {
          described_class.new.call
        }.not_to change(duplicated_preference.reload, :status)
      end
    end

    context 'when application_form has not been submitted' do
      it 'does not publish duplicate preference' do
        application_form = create(
          :application_form,
          :completed,
        )
        _published_preference = create(
          :candidate_preference,
          application_form:,
          updated_at: 2.days.ago,
        )
        duplicated_preference = create(
          :candidate_preference,
          :duplicated,
          application_form:,
        )

        expect {
          described_class.new.call
        }.not_to change(duplicated_preference.reload, :status)
      end
    end
  end
end

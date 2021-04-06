require 'rails_helper'

RSpec.describe SupportInterface::NotesExport do
  describe 'documentation' do
    before do
      candidate = create(:candidate)
      training_provider = create(:provider)
      course = create(:course, provider: training_provider)
      application_choice = create(:application_choice, candidate: candidate, course_option: create(:course_option, course: course))
      provider_user = create(:provider_user, providers: [training_provider])

      create(:note, application_choice: application_choice, provider_user: provider_user)
    end

    it_behaves_like 'a data export'
  end

  describe 'data_for_export' do
    it 'returns a hash of notes data' do
      candidate = create(:candidate)
      training_provider = create(:provider)
      ratifying_provider = create(:provider)
      course = create(:course, provider: training_provider, accredited_provider: ratifying_provider)
      application_choice1 = create(:application_choice, candidate: candidate, course_option: create(:course_option, course: course))
      application_choice2 = create(:application_choice, candidate: candidate, current_course_option: create(:course_option, course: course))
      provider_user1 = create(:provider_user, providers: [training_provider, ratifying_provider])
      provider_user2 = create(:provider_user, providers: [ratifying_provider])
      create(:provider_relationship_permissions, training_provider: training_provider, ratifying_provider: ratifying_provider)
      create(:provider_relationship_permissions, training_provider: create(:provider), ratifying_provider: training_provider)
      note1 = create(:note, application_choice: application_choice1, provider_user: provider_user1)
      note2 = create(:note, application_choice: application_choice2, provider_user: provider_user2)

      data = described_class.new.data_for_export

      expect(data).to match_array([
        {
          note_subject: note1.subject,
          note_message: note1.message,
          note_created_at: note1.created_at.iso8601,
          candidate_id: candidate.id,
          provider_code: training_provider.code,
          provider_name: training_provider.name,
          provider_user_id: provider_user1.id,
          number_of_training_provider_relationships: 1,
          total_number_of_provider_relationships: 2,
        },
        {
          note_subject: note2.subject,
          note_message: note2.message,
          note_created_at: note2.created_at.iso8601,
          candidate_id: candidate.id,
          provider_code: ratifying_provider.code,
          provider_name: ratifying_provider.name,
          provider_user_id: provider_user2.id,
          number_of_training_provider_relationships: 0,
          total_number_of_provider_relationships: 1,
        },
      ])
    end

    it 'omits provider org data if the provider user is no longer related to the offered course' do
      candidate = create(:candidate)
      training_provider1 = create(:provider)
      training_provider2 = create(:provider)
      ratifying_provider = create(:provider)

      course = create(:course, provider: training_provider1, accredited_provider: ratifying_provider)
      current_course = create(:course, provider: training_provider2, accredited_provider: ratifying_provider)

      application_choice = create(:application_choice, candidate: candidate, course_option: create(:course_option, course: course), current_course_option: create(:course_option, course: current_course))

      provider_user1 = create(:provider_user, providers: [training_provider1])
      provider_user2 = create(:provider_user, providers: [training_provider2])

      create(:provider_relationship_permissions, training_provider: training_provider1, ratifying_provider: ratifying_provider)
      create(:provider_relationship_permissions, training_provider: training_provider2, ratifying_provider: ratifying_provider)

      note1 = create(:note, application_choice: application_choice, provider_user: provider_user1)
      note2 = create(:note, application_choice: application_choice, provider_user: provider_user2)

      data = described_class.new.data_for_export

      expect(data).to match_array([
        {
          note_subject: note1.subject,
          note_message: note1.message,
          note_created_at: note1.created_at.iso8601,
          candidate_id: candidate.id,
          provider_code: nil,
          provider_name: nil,
          provider_user_id: provider_user1.id,
          number_of_training_provider_relationships: nil,
          total_number_of_provider_relationships: nil,
        },
        {
          note_subject: note2.subject,
          note_message: note2.message,
          note_created_at: note2.created_at.iso8601,
          candidate_id: candidate.id,
          provider_code: training_provider2.code,
          provider_name: training_provider2.name,
          provider_user_id: provider_user2.id,
          number_of_training_provider_relationships: 1,
          total_number_of_provider_relationships: 1,
        },
      ])
    end
  end
end

module SupportInterface
  class NotesExport
    def data_for_export(*)
      notes = Note.select(:application_choice_id, :message, :created_at, :user_id, :user_type, 'ARRAY_AGG(providers.id)')
                .joins("JOIN provider_users_providers ON notes.user_id = provider_users_providers.provider_user_id AND notes.user_type = 'ProviderUser'")
                .joins('JOIN providers ON provider_users_providers.provider_id = providers.id')
                .includes(
                  { application_choice: [{ application_form: :candidate }, { course_option: { course: %i[provider accredited_provider] } }] },
                )
                .group(:application_choice_id, :message, :created_at, :user_id, :user_type)

      notes.map do |note|
        providers = note.user.providers
        course = note.application_choice.current_course
        training_provider = course.provider
        ratifying_provider = course.accredited_provider

        provider = if providers.include?(training_provider)
                     training_provider
                   elsif providers.include?(ratifying_provider)
                     ratifying_provider
                   end

        training_org_permissions_count = nil
        total_org_permissions_count = nil

        if provider.present?
          training_org_permissions_count = provider.training_provider_permissions.count
          total_org_permissions_count = training_org_permissions_count + provider.ratifying_provider_permissions.count
        end

        {
          note_message: note.message,
          note_created_at: note.created_at.iso8601,
          candidate_id: note.application_choice.application_form.candidate.id,
          provider_code: provider&.code,
          provider_name: provider&.name,
          provider_user_id: note.user_id,
          number_of_training_provider_relationships: training_org_permissions_count,
          total_number_of_provider_relationships: total_org_permissions_count,
        }
      end
    end
  end
end

module SupportInterface
  class NotesExport
    def data_for_export
      notes = Note.select(:subject, :message, :created_at, :application_choice_id, :provider_user_id)
                .includes(
                  { provider_user: { provider_permissions: :provider } },
                  { application_choice: [{ application_form: :candidate }, { course_option: { course: %i[provider accredited_provider] } }] },
                )

      notes.map do |note|
        providers = note.provider_user.providers
        course = note.application_choice.offered_course_option&.course || note.application_choice.course_option.course
        training_provider = course.provider
        ratifying_provider = course.accredited_provider

        provider = providers.find { |p| p == training_provider || p == ratifying_provider }
        training_org_permissions_count = nil
        total_org_permissions_count = nil

        if provider.present?
          training_org_permissions_count = provider.training_provider_permissions.count
          total_org_permissions_count = training_org_permissions_count + provider.ratifying_provider_permissions.count
        end

        {
          note_subject: note.subject,
          note_message: note.message,
          note_created_at: note.created_at,
          candidate_id: note.application_choice.application_form.candidate.id,
          provider_code: provider&.code,
          provider_name: provider&.name,
          provider_user_id: note.provider_user_id,
          number_of_training_provider_relationships: training_org_permissions_count,
          total_number_of_provider_relationships: total_org_permissions_count,
        }
      end
    end
  end
end

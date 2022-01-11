module DataMigrations
  class BackfillUserColumnsOnNotes
    TIMESTAMP = 20220111125623
    MANUAL_RUN = false

    def change
      Note.where(user: nil).find_each do |note|
        note.update(user_id: note.provider_user_id, user_type: 'ProviderUser')
      end
    end
  end
end

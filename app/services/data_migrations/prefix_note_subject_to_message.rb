module DataMigrations
  class PrefixNoteSubjectToMessage
    TIMESTAMP = 20210505183930
    MANUAL_RUN = true

    def change
      ActiveRecord::Base.no_touching do
        Note.all.each do |note|
          message = "Subject: #{note.subject}\r\n\r\n#{note.message}"
          note.update(message: message)
        end
      end
    end
  end
end

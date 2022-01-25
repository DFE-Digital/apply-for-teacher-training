module VendorAPI
  class NotePresenter < Base
    attr_reader :note

    def initialize(version, note)
      super(version)
      @note = note
    end

    def to_json(_)
      schema.to_json
    end

    def schema
      {
        id: note.id.to_s,
        author: note.user.full_name,
        message: note.message,
        created_at: note.created_at.iso8601,
        updated_at: note.updated_at.iso8601,
      }
    end
  end
end

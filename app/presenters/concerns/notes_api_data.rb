module NotesAPIData
  def schema
    super.deep_merge!({
      attributes: {
        notes: notes.map { |note| VendorAPI::NotePresenter.new(active_version, note).schema },
      },
    })
  end

  def notes
    application_choice.notes.order(created_at: :desc)
  end
end

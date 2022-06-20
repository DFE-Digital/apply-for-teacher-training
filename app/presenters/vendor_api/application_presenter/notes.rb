module VendorAPI::ApplicationPresenter::Notes
  def schema
    super.deep_merge!({
      attributes: {
        notes: notes.map { |note| VendorAPI::NotePresenter.new(active_version, note).schema },
      },
    })
  end

  def notes
    application_choice.notes.sort_by(&:created_at).reverse
  end
end

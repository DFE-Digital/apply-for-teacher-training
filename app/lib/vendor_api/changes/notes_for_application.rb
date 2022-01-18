module VendorAPI
  module Changes
    class NotesForApplication < VersionChange
      description 'Includes notes associated with the application'

      action ApplicationsController, :show

      resource NotePresenter
      resource ApplicationPresenter, [NotesAPIData]
    end
  end
end

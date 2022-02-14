module VendorAPI
  module Changes
    class NotesForApplication < VersionChange
      description 'Includes notes associated with the application'

      resource NotePresenter
      resource ApplicationPresenter, [ApplicationPresenter::Notes]
    end
  end
end

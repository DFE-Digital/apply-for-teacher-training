module VendorAPI
  module Changes
    class NotesForApplications < VersionChange
      description 'Includes notes associated with applications'

      action ApplicationsController, :index

      resource ApplicationPresenter, [NotesPresenter]
    end
  end
end

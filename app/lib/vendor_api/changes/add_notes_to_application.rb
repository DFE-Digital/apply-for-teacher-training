module VendorAPI
  module Changes
    class AddNotesToApplication < VersionChange
      description 'Includes notes associated with the application'

      resource NotePresenter
      resource ApplicationPresenter, [ApplicationPresenter::Notes]
    end
  end
end

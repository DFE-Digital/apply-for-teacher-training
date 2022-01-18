module VendorAPI
  module Changes
    class CreateNote < VersionChange
      description 'Add a note to an application'

      action NotesController, :create
    end
  end
end

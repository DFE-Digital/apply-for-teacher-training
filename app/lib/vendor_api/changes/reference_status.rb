module VendorAPI
  module Changes
    class ReferenceStatus < VersionChange
      description 'Change the status of a reference in sandbox.'

      def actions
        {
          ReferencesController => %i[success failure],
        }
      end
    end
  end
end

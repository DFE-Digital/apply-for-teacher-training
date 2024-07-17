module VendorAPI
  module Changes
    class RefactoredReferenceOnApplication < VersionChange
      description 'Refactored Reference object on Application'

      resource ReferencePresenter
    end
  end
end

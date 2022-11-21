module VendorAPI
  module Changes
    module WorkHistory
      class AddRelevantSkillsBoolean < VersionChange
        description 'Add `skills_relevant_to_teaching` boolean to work and volunteering experience entries'

        resource ApplicationPresenter
      end
    end
  end
end

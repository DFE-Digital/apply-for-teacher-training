module DataMigrations
  class DropSupportUserChangeOfferedCourseFeatureFlag
    TIMESTAMP = 20220301180044
    MANUAL_RUN = false

    def change
      Feature.where(name: :support_user_change_offered_course).first&.destroy
    end
  end
end

module DataMigrations
  class DropChangeCourseDetailsBeforeOfferFeatureFlag
    TIMESTAMP = 20220427175552
    MANUAL_RUN = false

    def change
      Feature.where(name: :change_course_details_before_offer).first&.destroy
    end
  end
end

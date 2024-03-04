module DataMigrations
  class RemoveCourseHasVacanciesFeatureFlag
    TIMESTAMP = 20240304165105
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :course_has_vacancies)&.destroy
    end
  end
end

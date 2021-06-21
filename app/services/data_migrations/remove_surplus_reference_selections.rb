module DataMigrations
  class RemoveSurplusReferenceSelections
    TIMESTAMP = 20210616160559
    MANUAL_RUN = false

    def change
      unsubmitted_apps = retrieve_apps_with_surplus_reference_selections.select do |app|
        app.application_choices.map(&:status).all? { |s| s == 'unsubmitted' }
      end

      unsubmitted_apps.each { |a| a.application_references.update_all(selected: false) }

      remaining_apps = retrieve_apps_with_surplus_reference_selections
      remaining_apps.each do |application|
        selected_references = application.application_references.selected
        surplus_count = selected_references.size - 2
        selected_references.limit(surplus_count).update_all(selected: false)
      end
    end

  private

    def retrieve_apps_with_surplus_reference_selections
      ApplicationForm.joins(:application_references)
        .where(references: { selected: true })
        .group('"application_forms".id')
        .having('COUNT("references".id) > 2')
    end
  end
end

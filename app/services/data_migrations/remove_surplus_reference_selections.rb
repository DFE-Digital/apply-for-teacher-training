module DataMigrations
  class RemoveSurplusReferenceSelections
    TIMESTAMP = 20210616160559
    MANUAL_RUN = false

    def change
      selected_reference_counts =
        ApplicationForm.joins(:application_references)
        .where(references: { selected: true })
        .group('id')
        .select('"application_forms".id, COUNT("references".id) AS ref_count')

      applications_with_surplus_selections =
        ApplicationForm.where(
          id: selected_reference_counts.select { |c| c.ref_count > 2 }.map(&:id),
        )

      applications_with_surplus_selections.each do |application|
        selected_references = application.application_references.selected
        surplus_count = selected_references.size - 2
        selected_references.limit(surplus_count).update_all(selected: false)
      end
    end
  end
end

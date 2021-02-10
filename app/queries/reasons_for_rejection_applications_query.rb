class ReasonsForRejectionApplicationsQuery
  attr_accessor :filters

  def initialize(filters)
    self.filters = filters
  end

  def call
    application_choices = ApplicationChoice
      .where
      .not(structured_rejection_reasons: nil)
      .order(created_at: :desc)
      .page(filters[:page])
      .per(30)

    apply_filters(application_choices)
  end

private

  def apply_filters(application_choices)
    filters[:structured_rejection_reasons].each do |key, value|
      if key =~ /_y_n$/
        application_choices = application_choices.where(
          "application_choices.structured_rejection_reasons->>'#{key}' = '#{value}'",
        )
      else
        application_choices = application_choices.where(
          "application_choices.structured_rejection_reasons->'#{key}' ? '#{value}'",
        )
      end
    end

    application_choices
  end
end

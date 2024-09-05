class WarmCache
  def call
    r = {}
    # Get all provider who have an api token that has been used in the past 6.months
    Provider.joins(:vendor_api_tokens)
      .where('vendor_api_tokens.last_used_at > ?', 1.month.ago).distinct.each do |provider|
      Rails.logger.tagged('Warm Cache').info "Provider cached: #{provider.id}"
      # Find the api version they last used
      vendor_version = VendorAPIRequest
        .where(provider_id: provider.id)
        .select("regexp_matches(request_path, '/api/v(.*)/applications') result")
        .order(created_at: :desc)
        .first&.result&.first

      # skip as we couldn't find any api requests
      next unless vendor_version

      r[provider.name] = []

      # For each of the application choices
      # generate a cache entry
      ApplicationChoice.joins(course_option: { course: :provider })
        .where(course_options: { courses: { provider_id: provider.id } })
        .where('application_choices.updated_at between (?) and (?)', Date.new(2024, 9, 2), Date.new(2024, 9, 5))
        .where.not(application_choices: { status: ['unsubmitted'] })
        .find_each do |application_choice|
        presenter = VendorAPI::ApplicationPresenter.new(vendor_version, application_choice)
        presenter.as_json
        presenter.serialized_json
        Rails.logger.tagged('Warm Cache').info "ApplicationChoice cached: #{application_choice.id}"
        r[provider.name] << application_choice.id
      end
    end
    r
  end
end

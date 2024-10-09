module VendorAPI::MultipleApplicationsPresenter::Pagination
  include Pagy::Backend

  DEFAULT_PER_PAGE = 50
  MAX_PER_PAGE = 50

  def serialized_applications_data
    %({"data":[#{serialized_applications.join(',')}], "links": #{links.to_json}, "meta": #{VendorAPI::MetaPresenter.new(active_version, total_count).as_json}})
  end

  def links
    {
      first: @pagy_meta[:first_url] || options[:url],
      last: @pagy_meta[:last_url] || options[:url],
      self: @pagy_meta[:page_url] || options[:url],
      prev: @pagy_meta[:prev_url] || options[:url],
      next: @pagy_meta[:next_url] || options[:url],
    }
  end

  def no_pagination?
    options[:per_page].nil? && options[:page].nil?
  end

  def applications_scope
    @pagy_meta = {}
    if no_pagination?
      applications.find_each(batch_size: 500)
                  .sort_by(&:updated_at)
                  .reverse
    else
      paginate(applications.order('application_choices.updated_at DESC'))
    end
  end

  def total_count
    @pagy&.count || applications.size
  end

  def paginate(scope)
    @pagy, paginated_records = pagy(scope, limit: per_page, page:, overflow: :exception)
    @pagy_meta = pagy_metadata(@pagy, absolute: true) || {}

    paginated_records
  end

  def per_page
    raise PerPageParameterInvalid unless options[:per_page].to_i <= MAX_PER_PAGE

    [(options[:per_page] || DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE].min
  end

  def page
    (options[:page].presence || 1).to_i
  end
end

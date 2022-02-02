module PaginationAPIData
  include Pagy::Backend

  DEFAULT_PER_PAGE = 50
  MAX_PER_PAGE = 50

  def serialized_applications_data
    %({"data":[#{serialized_applications.join(',')}], "links": #{links.to_json}, "meta": #{VendorAPI::MetaPresenter.new(active_version, @pagy.count).as_json}})
  end

  def links
    url = options[:url]
    link_options = options.except(:url, :api_version)
    links_hash = {
      first: pagination_link(url, link_options, 1),
      last: pagination_link(url, link_options, @pagy.last),
      self: pagination_link(url, link_options, @pagy.page),
    }
    links_hash[:prev] = pagination_link(url, link_options, @pagy.prev) if @pagy.prev
    links_hash[:next] = pagination_link(url, link_options, @pagy.next) if @pagy.next

    links_hash
  end

  def meta
    {
      api_version: options[:api_version],
      timestamp: Time.zone.now.iso8601,
      total_count: @pagy.count,
    }
  end

  def serialized_applications
    paginate(applications).map do |application|
      VendorAPI::ApplicationPresenter.new(active_version, application).serialized_json
    end
  end

  def pagination_link(url, options, page)
    "#{url}?#{build_query(options.merge(page: page.to_s))}"
  end

  def paginate(scope)
    @pagy, paginated_records = pagy(scope, items: per_page, page: page)

    paginated_records
  end

  def per_page
    [(options[:per_page] || DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE].min
  end

  def page
    (options[:page] || 1).to_i
  end

  def build_query(params)
    params.stringify_keys.map do |k, v|
      if v.instance_of?(Array)
        build_query(v.map { |x| [k, x] })
      else
        "#{k}=#{v}"
      end
    end.join('&')
  end
end

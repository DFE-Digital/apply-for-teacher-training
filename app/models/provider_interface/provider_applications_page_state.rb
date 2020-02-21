module ProviderInterface
  class ProviderApplicationsPageState
    attr_reader :sort_order, :sort_by, :filter_visible, :filter_options

    def initialize(params:)
      @params = params
      @sort_order = params[:sort_order].eql?('asc') ? 'asc' : 'desc'
      @sort_by = params[:sort_by].presence || 'last-updated'
      @filter_visible = params['filter_visible'] ||= 'true'
      @filter_options = extract_filter_options
    end

    def ordering_arguments
      {
        'course' => { 'courses.name' => sort_order },
        'last-updated' => { 'application_choices.updated_at' => sort_order },
        'name' => { 'last_name' => sort_order, 'first_name' => sort_order },
      }[@sort_by]
    end

  private

    def extract_filter_options
      # i.e. url params
      if @params[:filter].is_a?(Array)
        @params[:filter]
      else
        # i.e. form params
        @params.fetch('filter', false) ? @params['filter']['status'].keys : []
      end
    end
  end
end

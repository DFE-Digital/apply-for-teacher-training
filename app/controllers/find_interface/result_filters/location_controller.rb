module FindInterface
  module ResultFilters
    class LocationController < FindInterfaceController

      include FilterParameters

      before_action :build_results_filter_query_parameters

      def new; end

      def start
        flash[:start_wizard] = true
      end

      def create
        # if searching for specific provider go to results page
        if provider_option_selected?
          redirect_to(find_interface_provider_path(get_params_for_selected_option({})))
          return
        end

        form_params = strip(filter_params.clone).merge(sortby: ResultsView::DISTANCE)
        form_object = LocationFilterForm.new(form_params)

        if form_object.valid?
          parameters_with_geocode_added_and_previous_removed = remove_previous_parameters(form_params.merge(form_object.params))
          redirect_to(next_step(parameters_with_geocode_added_and_previous_removed))
        else
          flash[:error] = form_object.errors
          back_to_current_page_if_error(merge_previous_parameters(form_params))
        end
      end

    private

      def build_results_filter_query_parameters
        @results_filter_query_parameters = merge_previous_parameters(
          ResultsView.new(query_parameters: request.query_parameters).query_parameters_with_defaults,
        )
      end

      def location_option_selected?
        filter_params[:l] == "1"
      end

      def across_england_option_selected?
        filter_params[:l] == "2"
      end

      def provider_option_selected?
        filter_params[:l] == "3"
      end

      def get_params_for_selected_option(all_params)
        if location_option_selected?
          all_params.except(:query).merge(rad: ResultsView::MILES)
        elsif across_england_option_selected?
          all_params.except(:lat, :lng, :rad, :loc, :lq, :query, :sortby)
        elsif provider_option_selected?
          filter_params.except(:lat, :lng, :rad, :loc, :lq)
        end
      end

      def strip(params)
        params.reject { |_, v| v == "" }
      end

      def next_step(all_params)
        submitted_params = get_params_for_selected_option(all_params)
        if flash[:start_wizard]
          start_subject_path(submitted_params)
        else
          results_path(submitted_params)
        end
      end

      def back_to_current_page_if_error(form_params)
        if flash[:start_wizard] #&& Settings.cycle_ending_soon
          # In this scenario we do not want to redirect to 'root_path'
          # because root_path is '/cycle-ending-soon' and the
          # validation errors will be lost
          redirect_to find_interface_location_path(form_params)
        elsif flash[:start_wizard] #&& !Settings.cycle_ending_soon
          redirect_to root_path(form_params)
        else
          redirect_to find_interface_location_path(form_params)
        end
      end
    end
  end
end

module CandidateInterface
  module PreviousTeacherTraining
    class DatesController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_back_path

      def edit
        @form = ::PreviousTeacherTraining::Dates.find_or_initialize_by(
          application_form: current_application,
        )
      end

      def update
        @form = ::PreviousTeacherTraining::Dates.find_or_initialize_by(
          application_form: current_application,
        )
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to @back_path || edit_candidate_interface_previous_teacher_training_details_path
        else
          render :edit
        end
      end

    private

      def request_params
        params.expect(
          previous_teacher_training_dates: [
            'started_at(1i)',
            'started_at(2i)',
            'started_at(3i)',
            'ended_at(1i)',
            'ended_at(2i)',
            'ended_at(3i)',
          ],
        ).transform_keys { |key| start_date_field_to_attribute(key, 'started_at') }
        .transform_keys { |key| end_date_field_to_attribute(key, 'ended_at') }
      end

      def set_back_path
        if params[:return_to] == 'review'
          @back_path = candidate_interface_previous_teacher_training_review_path
        end
      end
    end
  end
end

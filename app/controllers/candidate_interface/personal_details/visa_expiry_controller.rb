module CandidateInterface
  module PersonalDetails
    class VisaExpiryController < CandidateInterfaceController
      before_action :redirect_personal_details_unless_temporary_imigration
      before_action :set_back_links, only: %i[new create]

      def new
        @form = VisaExpiryForm.new(current_application)
      end

      def edit
        @form = VisaExpiryForm.new(current_application)
      end

      def create
        @form = VisaExpiryForm.new(current_application)
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to candidate_interface_personal_details_show_path
        else
          render :new
        end
      end

      def update
        @form = VisaExpiryForm.new(current_application)
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to candidate_interface_personal_details_show_path
        else
          render :edit
        end
      end

    private

      def redirect_personal_details_unless_temporary_imigration
        unless current_application.temporary_immigration_status?
          redirect_to candidate_interface_personal_details_show_path
        end
      end

      def set_back_links
        if params['return-to'] == 'application-review'
          @back_link = candidate_interface_personal_details_show_path
          @submit_params = { 'return-to' => 'application-review' }
        else
          @back_link = candidate_interface_immigration_status_path
        end
      end

      def request_params
        params.expect(
          candidate_interface_visa_expiry_form: [
            'visa_expired_at(3i)',
            'visa_expired_at(2i)',
            'visa_expired_at(1i)',
          ],
        ).transform_keys { |key| start_date_field_to_attribute(key, 'visa_expired_at', 'visa_expired') }
      end
    end
  end
end

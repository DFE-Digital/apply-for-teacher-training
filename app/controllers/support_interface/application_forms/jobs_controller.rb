module SupportInterface
  module ApplicationForms
    class JobsController < SupportInterfaceController
      before_action :build_application_form

      def edit
        @job_form = JobForm.build_form(job)
      end

      def update
        @job_form = JobForm.new(job_form_params)

        if @job_form.update(job)
          flash[:success] = 'Job updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          @job_form.cast_booleans
          render :edit
        end
      end

    private

      def build_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def job
        @application_form
          .application_work_experiences
          .find(job_params[:job_id])
      end

      def job_params
        params.permit(:job_id)
      end

      def job_form_params
        StripWhitespace.from_hash(
          params
                .expect(
                  support_interface_application_forms_job_form: %i[role
                                                                   organisation
                                                                   commitment
                                                                   start_date(3i)
                                                                   start_date(2i)
                                                                   start_date(1i)
                                                                   start_date_unknown
                                                                   currently_working
                                                                   end_date(3i)
                                                                   end_date(2i)
                                                                   end_date(1i)
                                                                   end_date_unknown
                                                                   relevant_skills
                                                                   audit_comment],
                )
                .transform_keys { |key| start_date_field_to_attribute(key) }
                .transform_keys { |key| end_date_field_to_attribute(key) },
        )
      end
    end
  end
end

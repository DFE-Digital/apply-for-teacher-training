module SupportInterface
  module ApplicationForms
    class CommentsController < SupportInterfaceController
      def new
        @application_comment = ApplicationCommentForm.new
      end

      def create
        @application_comment = ApplicationCommentForm.new(application_comment_params)

        if @application_comment.save(application_form)
          redirect_to support_interface_application_form_audit_path(application_form)
        else
          render :new
        end
      end

    private

      def application_form
        ApplicationForm.find(params[:application_form_id])
      end

      def application_comment_params
        params.require(:support_interface_application_comment_form).permit(
          :comment,
        )
      end
    end
  end
end

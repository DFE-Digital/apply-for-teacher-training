module SupportInterface
  module ApplicationForms
    class PersonalStatementController < SupportInterfaceController
      before_action :build_application_form

      def edit_becoming_a_teacher
        @becoming_a_teacher_form = EditBecomingATeacherForm.build_from_application(@application_form)
      end

      def update_becoming_a_teacher
        @becoming_a_teacher_form = EditBecomingATeacherForm.new(becoming_a_teacher_params)

        if @becoming_a_teacher_form.save(@application_form)
          flash[:success] = 'Personal statement updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit_becoming_a_teacher
        end
      end

      def edit_subject_knowledge
        @subject_knowledge_form = EditSubjectKnowledgeForm.build_from_application(@application_form)
      end

      def update_subject_knowledge
        @subject_knowledge_form = EditSubjectKnowledgeForm.new(subject_knowledge_params)

        if @subject_knowledge_form.save(@application_form)
          flash[:success] = 'Subject knowledge updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit_subject_knowledge
        end
      end

    private

      def becoming_a_teacher_params
        StripWhitespace.from_hash params
          .require(:support_interface_application_forms_edit_becoming_a_teacher_form)
          .permit(:becoming_a_teacher, :audit_comment)
      end

      def subject_knowledge_params
        StripWhitespace.from_hash params
          .require(:support_interface_application_forms_edit_subject_knowledge_form)
          .permit(:subject_knowledge, :audit_comment)
      end

      def build_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end
    end
  end
end

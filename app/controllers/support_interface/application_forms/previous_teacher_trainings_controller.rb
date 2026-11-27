module SupportInterface
  module ApplicationForms
    class PreviousTeacherTrainingsController < SupportInterfaceController
      include AuthorizeSupportUserCandidateEditable

      before_action :set_application_form
      before_action :set_previous_teacher_training, except: %i[new_teacher_training create_teacher_training]

      def edit_declaration
        @form = SupportInterface::ApplicationForms::PreviousTeacherTrainings::DeclarationForm.new(@previous_teacher_training)
      end

      def update_declaration
        @form = SupportInterface::ApplicationForms::PreviousTeacherTrainings::DeclarationForm.new(@previous_teacher_training)
        @form.assign_attributes(update_declaration_params)

        if @form.save
          flash[:success] = 'Previous teacher training updated'
          redirect_to @form.next_path
        else
          render :edit_declaration
        end
      end

      def new_teacher_training
        @form = SupportInterface::ApplicationForms::PreviousTeacherTrainings::TeacherTrainingForm.new(
          PreviousTeacherTraining.new(application_form: @application_form),
        )
      end

      def edit_teacher_training
        @form = SupportInterface::ApplicationForms::PreviousTeacherTrainings::TeacherTrainingForm.new(@previous_teacher_training)
      end

      def create_teacher_training
        @previous_teacher_training = PreviousTeacherTraining.new(application_form: @application_form)
        @form = SupportInterface::ApplicationForms::PreviousTeacherTrainings::TeacherTrainingForm.new(
          @previous_teacher_training,
        )
        @form.assign_attributes(teacher_training_params)

        if @form.save
          flash[:success] = 'Previous teacher training updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :new_teacher_training
        end
      end

      def update_teacher_training
        @form = SupportInterface::ApplicationForms::PreviousTeacherTrainings::TeacherTrainingForm.new(@previous_teacher_training)
        @form.assign_attributes(teacher_training_params)

        if @form.save
          flash[:success] = 'Previous teacher training updated'
          redirect_to support_interface_application_form_path(@application_form)
        else
          render :edit_teacher_training
        end
      end

      def review
        @previous_teacher_trainings = @application_form.previous_teacher_trainings.published.order(:started_at, :ended_at)
      end

      def remove_teacher_training; end

      def destroy_teacher_training
        provider_name = @previous_teacher_training.provider_name
        @form = SupportInterface::ApplicationForms::PreviousTeacherTrainings::RemoveForm.new(@previous_teacher_training)
        @form.destroy

        flash[:success] = "Previous teacher training for #{provider_name} was deleted."
        redirect_to support_interface_application_form_path(@application_form)
      end

    private

      def set_application_form
        @application_form = ApplicationForm.find(params.expect(:application_form_id))
      end

      def set_previous_teacher_training
        @previous_teacher_training = @application_form.previous_teacher_trainings.find(params.expect(:previous_teacher_training_id))
      end

      def update_declaration_params
        params.expect(support_interface_application_forms_previous_teacher_trainings_declaration_form: %i[started audit_comment])
      end

      def teacher_training_params
        params.expect(
          support_interface_application_forms_previous_teacher_trainings_teacher_training_form: [:provider_name,
                                                                                                 :details,
                                                                                                 :audit_comment,
                                                                                                 [
                                                                                                   'started_at(1i)',
                                                                                                   'started_at(2i)',
                                                                                                   'started_at(3i)',
                                                                                                   'ended_at(1i)',
                                                                                                   'ended_at(2i)',
                                                                                                   'ended_at(3i)',
                                                                                                 ]],
        ).transform_keys { |key| start_date_field_to_attribute(key, 'started_at') }
              .transform_keys { |key| end_date_field_to_attribute(key, 'ended_at') }
      end
    end
  end
end

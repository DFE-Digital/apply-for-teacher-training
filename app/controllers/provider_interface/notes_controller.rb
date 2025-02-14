module ProviderInterface
  class NotesController < ProviderInterfaceController
    before_action :set_application_choice, :set_workflow_flags, :redirect_if_application_changed_provider

    def index
      @notes = @application_choice.notes.order('created_at DESC')
    end

    def show
      @note = @application_choice.notes.find(params[:id])
    end

    def new
      @new_note_form = ProviderInterface::NewNoteForm.new
    end

    def create
      @new_note_form = ProviderInterface::NewNoteForm.new(note_params)

      if @new_note_form.save
        flash[:success] = 'Note successfully added'
        redirect_to provider_interface_application_choice_notes_path(@application_choice)
      else
        track_validation_error(@new_note_form)
        render(action: :new)
      end
    end

  private

    def note_params
      params.require(:provider_interface_new_note_form).permit(:message, :referer)
        .merge(application_choice: @application_choice, user: current_provider_user)
    end
  end
end

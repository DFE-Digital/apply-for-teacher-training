module VendorAPI
  class NotesController < VendorAPIController
    before_action :validate_metadata!

    include ApplicationDataConcerns

    def create
      service = CreateNote.new(note_params)
      service.save!

      application_choice = application_choices_visible_to_provider.find(params[:application_id])

      render json: %({"data":#{ApplicationPresenter.new(version_number, application_choice).serialized_json}})
    rescue ActiveRecord::RecordInvalid
      render_validation_errors(service.errors)
    end

    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end

    def note_params
      {
        application_choice: application_choice,
        user: audit_user,
        message: params[:data][:message],
      }
    end
  end
end

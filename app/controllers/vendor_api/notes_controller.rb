module VendorAPI
  class NotesController < VendorAPIController
    include ApplicationDataConcerns
    include APIValidationsAndErrorHandling

    def create
      CreateNote.new(user: audit_user,
                     application_choice: application_choice,
                     message: message).save!

      render_application
    end

  private

    def message
      params.require(:data).permit(:message).tap do |data|
        data.require(:message)
      end[:message]
    end
  end
end

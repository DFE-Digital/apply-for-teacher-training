module VendorAPI
  class NotesController < VendorAPIController
    include ApplicationDataConcerns

    def create
      CreateNote.new(user: audit_user,
                     application_choice:,
                     message:).save!

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

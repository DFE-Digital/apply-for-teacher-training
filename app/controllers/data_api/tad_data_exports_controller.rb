module DataAPI
  class TADDataExportsController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :verify_token!

    def latest
      data_export = DataAPI::TADExport.latest
      data_export.update!(audit_comment: "File downloaded via API using token ID #{@authenticating_token.id}")
      send_data data_export.data, filename: data_export.filename
    end

  private

    def verify_token!
      unless authorized?
        render_error(
          name: 'Unauthorized',
          message: 'Please provide a valid API token',
          status: :unauthorized,
        )
      end
    end

    def authorized?
      authenticate_with_http_token do |token|
        @authenticating_token = AuthenticationToken.find_by_hashed_token(user_type: 'APIUser', raw_token: token)
        @authenticating_token.user_id == APIUser.tad_user.id
      end
    end

    def render_error(name:, message:, status:)
      response = { errors: [{ error: name, message: message }] }

      render json: response, status: status
    end
  end
end

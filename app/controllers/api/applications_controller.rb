class Api::ApplicationsController < ActionController::API
  def index
    render json: [
      {
        id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        first_name: 'hello',
        email: 'example@email.com'
      },
      {},
      {}
    ]
  end
end

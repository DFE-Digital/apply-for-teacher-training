class RefereeInterfaceRoutes < RouteExtension
  def routes
    get '/' => 'reference#feedback', as: :reference_feedback
    get '/confirmation' => 'reference#confirmation', as: :confirmation
    patch '/confirmation' => 'reference#submit_feedback', as: :submit_feedback

    patch '/confirm-consent' => 'reference#confirm_consent', as: :confirm_consent

    get '/refuse-feedback' => 'reference#refuse_feedback', as: :refuse_feedback
    patch '/refuse-feedback' => 'reference#confirm_feedback_refusal'
  end
end

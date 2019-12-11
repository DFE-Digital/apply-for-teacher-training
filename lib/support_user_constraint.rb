class SupportUserConstraint
  def matches?(request)
    current_support_user(request).present?
  end

private

  def current_support_user(request)
    SupportUser.load_from_session(request.session)
  end
end

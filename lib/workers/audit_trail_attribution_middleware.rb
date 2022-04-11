module Workers
  class AuditTrailAttributionMiddleware
    AUDIT_USER_NAME = '(Automated process)'.freeze

    def call(_worker, _msg, _queue)
      Audited.audit_class.as_user(AUDIT_USER_NAME) do
        yield
      end
    end
  end
end

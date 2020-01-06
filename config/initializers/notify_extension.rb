module Notifications
  class Client
    class RequestError < StandardError
      def to_s
        message
      end
    end
  end
end

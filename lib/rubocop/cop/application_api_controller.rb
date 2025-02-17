module RuboCop
  module Cop
    class ApplicationAPIController < Base
      extend AutoCorrector

      MSG = 'API controllers should subclass `ApplicationAPIController`.'.freeze
      SUPERCLASS = 'ApplicationAPIController'.freeze
      BASE_PATTERN = '(const (const nil? :ActionController) :API)'.freeze
    end
  end
end

module CandidateInterface
  module Concerns
    module FreeTextInputHelper
      def invalid_raw_data?
        return false if raw_input.nil?
        return false if value.blank?

        return false if valid_options.any? do |input_name, input_value|
          input_name == raw_input && input_value.to_s == value.to_s
        end

        true
      end
    end
  end
end

module TestHelpers
  module CaptureStdoutHelper
    def self.included(base)
      base.class_eval do
        around do |example|
          @old_stdout = $stdout
          @stdout_output = StringIO.new
          $stdout = @stdout_output
          example.run
          $stdout = @old_stdout
        end
      end
    end
  end
end

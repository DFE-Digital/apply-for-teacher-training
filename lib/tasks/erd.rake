# https://github.com/voormedia/rails-erd/pull/354/files
namespace :erd do
  desc 'Generate a relationship diagram based on our models'
  task :load_models do
    say 'Loading application environment...'
    Rake::Task[:environment].invoke

    say 'Loading code in search of Active Record models...'
    begin
      Rails.application.eager_load!
      if Rails.application.respond_to?(:config) && Rails.application.config.autoloader == :zeitwerk
        Zeitwerk::Loader.eager_load_all
      else
        Rails.application.eager_load!
      end

      if Rails.application.respond_to?(:config) &&
         !Rails.application.config.nil? &&
         Rails.application.config.respond_to?(:eager_load_namespaces)
        Rails.application.config.eager_load_namespaces.each(&:eager_load!)
      end
    rescue StandardError => e
      if Rake.application.options.trace
        raise
      else
        trace = Rails.backtrace_cleaner.clean(e.backtrace)
        error = (["Loading models failed!\nError occurred while loading application: #{e} (#{e.class})"] + trace).join("\n    ")
        raise error
      end
    end
    raise 'Active Record was not loaded.' unless defined? ActiveRecord
  end
end

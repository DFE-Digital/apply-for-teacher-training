module API
  class Base
    include Rails.application.routes.url_helpers

    attr_reader :active_version

    def initialize(active_version)
      @active_version = active_version

      self.class::VERSIONS.each do |version, modules|
        if active_version >= version
          modules.each do |mod|
            prependable = mod.constantize
            self.class.send(:prepend, prependable)
          end
        end
      end
    end
  end
end

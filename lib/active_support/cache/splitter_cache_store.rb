module ActiveSupport
  module Cache
    class SplitterCacheStore < Store
      attr_reader :caches

      def self.supports_cache_versioning?
        true
      end

      def initialize(options)
        # need to think about url
        @caches = options.delete(:caches).to_h do |name, cache_args|
          [name, ActiveSupport::Cache.lookup_store(cache_args)]
        end
        super
      end

      def fetch(name, options = nil, &)
        choose_cache(name).fetch(name, options, &)
      end

      def read(name, options = nil)
        choose_cache(name).read(name, options)
      end

      def write(name, value, options = nil)
        choose_cache(name).write(name, value, options)
      end

      def delete(name, options = nil)
        choose_cache(name).delete(name, options)
      end

      def increment(name, amount = 1, options = nil)
        choose_cache(name).increment(name, amount, **options)
      end

      def exist?(name, options = nil)
        choose_cache(name).exist?(name, options)
      end

      def clear(options = nil)
        caches[:redis].clear(options)
      end

    private

      def choose_cache(key)
        normalized_key = normalize_key(key)

        if normalized_key.include?('vendor_api')
          caches[:solid_cache]
        else
          caches[:redis]
        end
      end
    end
  end
end

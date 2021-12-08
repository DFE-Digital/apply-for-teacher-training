module APITest
  module TestModule
    VERSION = '1.0'.freeze

    def schema
      return super unless active_version >= VERSION

      super.merge!({
        one: 'two keys',
        two: 'two keys',
      })
    end
  end

  module SecondTestModule
    VERSION = '1.1'.freeze

    def schema
      return super unless active_version >= VERSION

      super.merge!({
        two: 'three keys',
      })
    end
  end

  class PresenterClass < VendorAPI::Base
    VERSIONS = {
      '1.0' => [TestModule],
      '1.1' => [SecondTestModule],
    }.freeze

    def schema
      { one: 'a key' }
    end
  end
end

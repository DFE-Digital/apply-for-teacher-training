module APITest
  module TestModule
    def schema
      super.merge!({
        one: 'two keys',
        two: 'two keys',
      })
    end
  end

  module SecondTestModule
    def schema
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

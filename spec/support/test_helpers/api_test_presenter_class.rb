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
    def schema
      { one: 'a key' }
    end
  end

  class FirstTestVersionChange < VersionChange
    resource PresenterClass
  end

  class SecondTestVersionChange < VersionChange
    resource PresenterClass, [TestModule]
  end

  class ThirdTestVersionChange < VersionChange
    resource PresenterClass, [SecondTestModule]
  end
end

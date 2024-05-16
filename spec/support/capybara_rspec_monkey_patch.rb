# Modify methods called by Capybara::RSpec so they work with :js specs and
# with rack_test
module CapybaraRSpecMonkeyPatch
  def check(locator = nil, **options)
    if self.class.metadata.keys.intersect?(%i[js js_browser])
      super(locator, **options.merge(visible: false))
    else
      super
    end
  end

  def select(value = nil, from: nil, **options)
    if has_css?('.autocomplete__wrapper input') && self.class.metadata.keys.intersect?(%i[js js_browser])

      input = find('.autocomplete__wrapper input')
      input.fill_in(with: value)
      input.send_keys(:down)
      page.send_keys(:enter)
    else
      super
    end
  end

  def uncheck(locator = nil, **options)
    if self.class.metadata.keys.intersect?(%i[js js_browser])
      super(locator, **options.merge(visible: false))
    else
      super
    end
  end

  def choose(locator = nil, **options)
    if self.class.metadata.keys.intersect?(%i[js js_browser])
      super(locator, **options.merge(visible: false))
    else
      super
    end
  end
end

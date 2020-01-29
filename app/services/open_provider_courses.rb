class OpenProviderCourses
  def initialize(provider:)
    @provider = provider
  end

  def call
    @provider.courses.exposed_in_find.update_all(open_on_apply: true)
  end
end

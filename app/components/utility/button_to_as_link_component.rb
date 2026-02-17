class ButtonToAsLinkComponent < ApplicationComponent
  def initialize(name:, path:, classes: [])
    @name = name
    @path = path
    @classes = classes
  end

private

  def styling_classes
    default = 'govuk-link govuk-link-button'

    @classes.each do |css_class|
      default << " #{css_class}"
    end

    default
  end
end

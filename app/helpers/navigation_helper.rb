module NavigationHelper
  def nav_link(text, url, active:)
    item_class = 'govuk-header__navigation-item'
    item_class += ' govuk-header__navigation-item--active' if controller.controller_name == active

    tag.li class: item_class do
      link_to text, url, class: 'govuk-header__link'
    end
  end
end

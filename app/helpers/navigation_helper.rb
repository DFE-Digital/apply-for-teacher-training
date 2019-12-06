module NavigationHelper
  def nav_link(text, url, active: [], active_action: [])
    item_class = 'govuk-header__navigation-item'
    item_class += ' govuk-header__navigation-item--active' if controller.controller_name.in?(Array.wrap(active))
    item_class += ' govuk-header__navigation-item--active' if controller.action_name.in?(Array.wrap(active_action))

    tag.li class: item_class do
      link_to text, url, class: 'govuk-header__link'
    end
  end
end

module ApplicationHelper
  def page_title(page)
    page_title_translation_key = "page_titles.#{page}"

    if I18n.exists?(page_title_translation_key)
      "#{t(page_title_translation_key)} - #{t('page_titles.application')}"
    else
      t('page_titles.application')
    end
  end
end

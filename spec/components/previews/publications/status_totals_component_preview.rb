module Publications
  class StatusTotalsComponentPreview < ViewComponent::Preview
    def default
      render_with_template(template: 'publications/status_totals/default')
    end
  end
end

module SupportInterface
  class DocsController < SupportInterfaceController
    def index; end

    def provider_flow; end

    def candidate_flow; end

    def qualifications; end

    def mailer_previews
      @previews = ActionMailer::Preview.all
      @page_title = 'Mailer Previews'
    end

    def component_previews
      @previews_grouped_by_namespace = ViewComponent::Preview.all.reverse.group_by { |p| p.name.split('::').first }
      @page_title = 'Components Previews'
    end
  end
end

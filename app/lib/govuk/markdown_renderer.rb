module Govuk
  class MarkdownRenderer < ::Redcarpet::Render::Safe
    def block_html(raw_html)
      # No user input HTML please
    end

    def raw_html(raw_html)
      # No user input HTML please
    end

    def emphasis(text)
      # Disable feature
    end

    def double_emphasis(text)
      # Disable feature
    end

    def triple_emphasis(text)
      # Disable feature
    end

    def list(content, list_type)
      case list_type
      when :ordered
        <<~HTML
          <ol class="govuk-list govuk-list--number">
            #{content}
          </ol>
        HTML
      when :unordered
        <<~HTML
          <ul class="govuk-list govuk-list--bullet">
            #{content}
          </ul>
        HTML
      end
    end

    def link(link, _title, content)
      %(<a href="#{link}" class="govuk-link">#{content}</a>)
    end

    def autolink(link, _link_type)
      %(<a href="#{link}" class="govuk-link">#{link}</a>)
    end

    def paragraph(text)
      %(<p class="govuk-body">#{text}</p>)
    end

    # Force all headers to <h3> to maintain semantic markup
    def header(text, _heading_level)
      %(<h3 class="govuk-heading-m">#{text}</h3>)
    end

    def self.render(content)
      Redcarpet::Markdown.new(self).render(content)
    end
  end
end

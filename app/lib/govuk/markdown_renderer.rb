module Govuk
  class MarkdownRenderer < ::Redcarpet::Render::Safe
    def table(header, body)
      <<~HTML
        <table class='govuk-table'>
          <thead class='govuk-table__head'>
            #{header}
          </thead>
          <tbody class='govuk-table__body'>
            #{body}
          </tbody>
        </table>
      HTML
    end

    def table_row(content)
      <<~HTML
        <tr class='govuk-table__row'>
          #{content}
        </tr>
      HTML
    end

    def table_cell(content, _alignment)
      <<~HTML
        <td class='govuk-table__cell'>
          #{content}
        </td>
      HTML
    end

    def self.render(content)
      Redcarpet::Markdown.new(self, tables: true).render(content)
    end
  end
end

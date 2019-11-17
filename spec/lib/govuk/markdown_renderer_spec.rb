require 'rails_helper'

# Ignore whitespace
def expect_equal_ignoring_ws(first, second)
  expect(first.lines.map(&:strip).join('')).to eq(second.lines.map(&:strip).join(''))
end

RSpec.describe Govuk::MarkdownRenderer do
  let(:html) { Govuk::MarkdownRenderer.render(markdown) }

  context 'table' do
    let(:markdown) do
      <<~MD
        | First name   | Last name    | DOB        |
        | ------------ | ------------ | ---------- |
        | John         | Smith        | 01-04-1970 |
        | Alison       | Brown        | 02-05-1970 |
        | Adam         | Sample       | 03-06-1970 |
      MD
    end

    it 'renders correct HTML' do
      expected_html = <<~HTML
        <table class='govuk-table'>
          <thead class='govuk-table__head'>
            <tr class='govuk-table__row'>
              <td class='govuk-table__cell'>First name</td>
              <td class='govuk-table__cell'>Last name</td>
              <td class='govuk-table__cell'>DOB</td>
            </tr>
          </thead>
          <tbody class='govuk-table__body'>
            <tr class='govuk-table__row'>
              <td class='govuk-table__cell'>John</td>
              <td class='govuk-table__cell'>Smith</td>
              <td class='govuk-table__cell'>01-04-1970</td>
            </tr>
            <tr class='govuk-table__row'>
              <td class='govuk-table__cell'>Alison</td>
              <td class='govuk-table__cell'>Brown</td>
              <td class='govuk-table__cell'>02-05-1970</td>
            </tr>
            <tr class='govuk-table__row'>
              <td class='govuk-table__cell'>Adam</td>
              <td class='govuk-table__cell'>Sample</td>
              <td class='govuk-table__cell'>03-06-1970</td>
            </tr>
          </tbody>
        </table>
      HTML

      expect_equal_ignoring_ws(html, expected_html)
    end
  end
end

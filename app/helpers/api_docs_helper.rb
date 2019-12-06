module ApiDocsHelper
  def json_code_sample(code)
    source = JSON.pretty_generate(code)
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::JSON.new

    tag.pre class: 'app-json-code-sample' do
      tag.code do
        formatter.format(lexer.lex(source)).html_safe
      end
    end
  end
end

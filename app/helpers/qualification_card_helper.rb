module QualificationCardHelper
  def sub_header_tag(header_tag:)
    "h#{header_tag.last.to_i + 1}"
  end
end

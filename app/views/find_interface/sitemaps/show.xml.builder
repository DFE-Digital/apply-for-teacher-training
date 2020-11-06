xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.9", "xmlns:xhtml" => "http://www.w3.org/1999/xhtml" do
  xml.url do
    xml.loc root_url
  end

  xml.url do
    xml.loc results_url
  end

  @courses.each do |course|
    xml.url do
      xml.loc course_url(course.provider_code, course.course_code)
      xml.lastmod course.changed_at.to_date.strftime("%Y-%m-%d")
    end
  end
end

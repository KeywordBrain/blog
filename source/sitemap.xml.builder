xml.instruct!
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  site_url = config[:page_config][:url]

  # Blog homepage
  xml.url do
    xml.loc site_url + "/#{config[:page_config][:prefix]}/"
    xml.changefreq 'daily'
    xml.priority 1.0
  end

  # Articles
  blog('blog').articles.each do |article|
    xml.url do
      xml.loc site_url + article.url
      xml.changefreq 'weekly'
      xml.priority 0.8
    end
  end
end

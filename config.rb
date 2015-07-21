PREFIX = 'blog'

set :css_dir,             PREFIX + '/stylesheets'
set :js_dir,              PREFIX + '/javascripts'
set :images_dir,          PREFIX + '/images'
set :partials_dir,        'partials'

set :markdown_engine,     :redcarpet

set :markdown, {
    strikethrough:                  true,
    autolink:                       true,
    footnotes:                      true,
    fenced_code_blocks:             true,
    disable_indented_code_blocks:   true,
    tables:                         true,
    with_toc_data:                  true
  }

set :haml, ugly: true

set :page_config, {
  name: 'KeywordBrain',
  url: 'https://keywordbrain.com',
  prefix: PREFIX
}

activate :blog do |blog|
  blog.name       = :blog
  blog.permalink  = "#{PREFIX}/:title"
  blog.sources    = 'articles/:year-:month-:day-:title.html'
  blog.layout     = :article
end

activate :directory_indexes

page "/#{PREFIX}/sitemap.xml", layout: false

module KeywordBrainPatches
  # Instance methods for article and pages
  class Middleman::Sitemap::Resource
    def id
      Digest::SHA1.hexdigest(url)[0...6]
    end

    def canonical
      @app.settings.page_config[:url] + (data.canonical || url)
    end

    def author
      author = @app.data.authors[data.author]
      raise "Author '#{data.author}' not found" unless author

      author
    end
  end
end

helpers do
  def friendly_date(date)
    time_format = if date.year == Time.now.year
      "%B %d."
    else
      "%B %d, %Y."
    end

    date.strftime(time_format)
  end
end

# Build-specific configuration
configure :build do
  activate :minify_javascript
  activate :minify_css
  activate :asset_hash

  # Only load DISQUS during build
  set :comments, true

  ignore '.DS_Store'
  ignore Regexp.new(/readme.md/i)
end

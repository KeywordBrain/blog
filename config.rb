PREFIX = 'blog'

set :css_dir,             'stylesheets'
set :js_dir,              'javascripts'
set :images_dir,          'images'

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

# Mount sitemap inside blog directory and don’t build original file
proxy "/#{PREFIX}/sitemap.xml", '/sitemap.xml'
page "/#{PREFIX}/sitemap.xml", layout: false
ignore '/sitemap.xml'

module KeywordBrainPatches
  # Instance methods for article and pages
  class Middleman::Sitemap::Resource
    def id
      Digest::SHA1.hexdigest(url)[0...6]
    end

    def canonical
      @app.settings.page_config[:url] + (data.canonical || url)
    end
  end
end

helpers do
  # Add the partial folder to the name when including it
  def partial(partial, *args)
    partial.prepend('partials/')
    super
  end
end

# Build-specific configuration
configure :build do
  activate :minify_javascript
  activate :minify_css
  activate :asset_hash

  ignore '.DS_Store'
  ignore Regexp.new(/readme.md/i)
end

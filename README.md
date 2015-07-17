# KeywordBrain Insights Blog

This repository contains the code and content to create the KeywordBrain
blog at https://keywordbrain.com/blog/

## Setup

This has been tested and developed using `ruby 2.2.2p95` but should run
fine on other versions as well.

Clone the repository, then

```bash
$ bundle install
$ bundle exec middleman
```

That will spawn a local dev server on `localhost:4567` that builds the
site on the fly so changes to content are reflected immediately.

### Build for production

```bash
$ bundle exec middeman build
```

That will build the site and put it in `./build/`.

## URLs

Format for permalinks: `https://keywordbrain.com/blog/article-slug/`

In production this blog is mounted on `/blog/`, which is why the `index.md`
file contains nothing but a link to the blog. This file will never be visible
to a user because nginx serves the files straight from `./build/blog/`.

## Article metadata

Articles are written in Markdown and YAML frontmatter at the top of the
file specifies metadata:

```yaml
title: Article Title which will be the <H1>
description: >
  The meta description goes here
```

## Smart defaults

The site contains smart defaults for some things, including:

- **canonicals** point to the articles URL
- **robot tags** set to `index,follow`
- **meta description** and **window title** are only set if present,
  allowing search engines to dynamically set them based on content
- a **sitemap** containing all articles

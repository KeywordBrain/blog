FROM tianon/true

MAINTAINER Max Lielje max@keywordbrain.com

ADD ./build /blog_blog

VOLUME /blog_data

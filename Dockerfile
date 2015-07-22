FROM tianon/true

MAINTAINER Max Lielje max@keywordbrain.com

ADD ./build /blog_data

VOLUME /blog_data

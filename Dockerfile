FROM ruby:3.4.4

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client chromium chromium-driver libvips

ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID app && \
    useradd -m -u $UID -g app app

WORKDIR /myapp
RUN chown app:app /myapp

COPY --chown=app:app Gemfile Gemfile.lock ./
USER app
RUN bundle install --jobs=4 --retry=3

COPY --chown=app:app . .

USER root
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3002
USER app
CMD ["rails", "server", "-b", "0.0.0.0"]
# Base image
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn

# Set working directory
WORKDIR /app

# Copy Gemfile first (for caching)
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy project
COPY . .

# Expose port
EXPOSE 3000

# Start Rails
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]

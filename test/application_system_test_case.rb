require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # using: :headless_chrome -> prevent chrome from opening

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--start-maximized")
    options.add_argument("--disable-features=VizDisplayCompositor")
  end
end

require 'yaml'
require 'require_all'
require_all 'support'

require "selenium-webdriver"

require 'rspec/expectations'

require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

require 'pry'

config_yml = YAML.load_file('config.yml')
raise "Empty config.yml" if not config_yml

TEST_ENV = ENV['TEST_ENV'].nil? ? (config_yml.keys.first if config_yml.size == 1) : ENV['TEST_ENV']
raise "Invalid TEST_ENV specified." if config_yml[TEST_ENV].nil?

TestConfig = config_yml[TEST_ENV]

# not all supported yet
browser_drivers = {"firefox" => :selenium, "chrome" => :chrome_driver, "phantomJS" => :poltergeist, "remote" => :remote_browser}

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = browser_drivers[TestConfig["browser"]]
  config.javascript_driver = browser_drivers[TestConfig["browser"]]
  config.app_host = TestConfig["browser"]
end

include Capybara::DSL

# login if end-user supplied a login method in /support/
if defined? login()
  visit TestConfig["login"]["url"]
  login(TestConfig["login"]["username"], TestConfig["login"]["password"])
end


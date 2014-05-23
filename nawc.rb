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

# hard coded for now
site_links = Array.new
link_file = File.open("sites/links", "r")
# FIXME: this should be an array of hashes
link_file.each_line do |line|
  site_links << line.split('|')
end

def wait_until_url (url)
  timeout = 60
  timeout.times do
    return if current_url == url
    sleep 1
  end
  raise "URL: #{url} did not load!"
end

def wait_until(proc)
  timeout = 60
  timeout.times do
    return if proc.call
    sleep 1
  end
end


# also harded for now
# also need to make the page search text optional (and/or as an xpath or object)

visit site_links[0][0]
# because waiting for page load is unimportant to Capybara
wait_until_url(site_links[0][0])

# find target text (e.g., some page content)
wait_until(Proc.new { page.has_text?(site_links[0][1]) } )

# do not find target text (e.g., page load indicator)
wait_until(Proc.new { page.has_no_text?(site_links[0][2]) } )

page.save_screenshot('sites/Screenshot 0.png')


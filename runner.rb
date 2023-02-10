require 'pry'
require 'logger'
require_relative './web_scraper'
require_relative './parser'
require_relative './file_manager'

CONFIGURATION = {
  work_dir: './crawl_dir',
  crawler_threads_count: 5,
  parser_threads_count: 5
}.freeze

file_manager = FileManager.instance
file_manager.work_dir = CONFIGURATION[:work_dir]

scraper = WebScraper.new(CONFIGURATION[:crawler_threads_count], file_manager)
scraper.scrape

# wait while srape finishes
# for good, these processes should be separated into different processes and work independently (for example under systemd or jenkins)
sleep(3600)

parser = Parser.new(CONFIGURATION[:parser_threads_count], file_manager)
parser.parse
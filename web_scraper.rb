require 'curb'
require_relative './helper'

class WebScraper
  ATTEMPT_COUNT = 3

  def initialize(threads_count, file_manager)
    @file_manager = file_manager
    @threads_count = threads_count
  end

  def scrape
    @file_manager.init_storage_dir
    todos_queue = Queue.new
    @file_manager.read_todos.each { |todo| todos_queue.push(todo) }

    Helper.do_by_multithreads(@threads_count) do |i|
      while todo = todos_queue.pop
        sleep(2)
        crawl(todo, i)
      end
    end
  end

  def crawl(todo, thread_number, attempt = 0)
    if scraped_before?(todo)
      puts "Skipped #{todo}, because it was crawled today earlier! Check data in #{@file_manager.generate_file_path(todo)}\n"
    else
      puts "Thread #{thread_number} crawl #{todo}\n"
      curl = Curl::Easy.perform(todo)
      @file_manager.save_chain(curl)
    end
  rescue Curl::Err::TimeoutError, Curl::Err::ConnectionFailedError => e
    p "Skipped #{todo} after #{ATTEMPT_COUNT} count" unless attempt < ATTEMPT_COUNT

    puts "Caught #{e.class}. Retry to crawl. Attempt is #{attempt}"
    crawl(todo, thread_number, attempt + 1)
  rescue Curl::Err => e
    puts "Caught #{e.class}!!! Recheck it"
  end

  def scraped_before?(url)
    Dir.entries(@file_manager.storage_dir_path).find { |file_name| file_name == @file_manager.generate_file_name(url) }
  end
end

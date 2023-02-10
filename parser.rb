require 'nokogiri'
require_relative 'helper'

class Parser
  def initialize(threads_count, file_manager)
    @threads_count = threads_count
    @file_manager = file_manager
  end

  def parse
    dir_path = @file_manager.storage_dir_path
    chain_queue = Queue.new
    Dir.entries(dir_path).each { |todo| chain_queue.push(todo) }

    Helper.do_by_multithreads(@threads_count) do
      while file_name = chain_queue.pop
        parse_chain("#{dir_path}/#{file_name}")
      end
    end
  end

  # just example how scraped pages can be processed
  def parse_chain(file_path)
    return 'File does not exist' unless File.file?(file_path)

    content = File.read(file_path)
    crawl_data = { url: content[/^.+?(?=\n)/], response_code: content[/(?<=Response code: )\d+/] }

    doc = Nokogiri::HTML.parse(content.gsub("\n", '')[/<.*>/])
    collected_info = doc.xpath('//h1[@itemprop="name"]')

    return p "\"#{collected_info.text}\" was collected from #{crawl_data[:url]}" if collected_info.any?

    p "Nothing was found on #{crawl_data[:url]}"
  end
end

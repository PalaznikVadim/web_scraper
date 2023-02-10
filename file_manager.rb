require 'digest/md5'
require 'singleton'

class FileManager
  include Singleton
  attr_accessor :work_dir

  def read_todos
    File.readlines("#{@work_dir}/todo/todo").map(&:chomp)
  end

  def save_chain(curl)
    file_path = generate_file_path(curl.url)
    p "Save #{curl.url} in #{file_path}"

    File.open(file_path, 'w') do |f|
      f.puts(curl.url)
      f.puts("Response code: #{curl.response_code}")
      f.puts(curl.body_str)
    end
  end

  def generate_file_name(url)
    Digest::MD5.hexdigest(url)
  end

  def generate_file_path(url)
    "#{storage_dir_path}#{generate_file_name(url)}"
  end

  def storage_dir_path
    "#{@work_dir}/done/#{Date.today}/"
  end

  def init_storage_dir
    Dir.mkdir("#{@work_dir}/done") unless Dir.exist?("#{@work_dir}/done")
    Dir.mkdir(storage_dir_path) unless Dir.exist?(storage_dir_path)
  end
end

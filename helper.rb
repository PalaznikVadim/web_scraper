class Helper

  def self.do_by_multithreads(thread_count)
    workers = thread_count.times.map do |i|
      Thread.new do
        begin
          yield i
        rescue ThreadError => e
          puts "Error: #{e.message}"
        end
      end
    end

    workers.each { |t| t.join 1 }
  end
end

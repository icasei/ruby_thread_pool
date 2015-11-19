class RubyThreadPool
  DEFAULT_POOL_SIZE=4

  def initialize size
    if size.nil?
      @size = DEFAULT_POOL_SIZE
    else
      @size = size
    end

    unless @size.is_a? Integer
      raise ArgumentError.new("[size] needs to be an integer.")
    end

    @jobs = Queue.new

    @processing = false
    @callback = nil
    @exception_callback = nil
  end

  def queue_worker_thread *args, &delegate
    if delegate.nil?
      raise ArgumentError.new("[delegate] must not be nil.")
    end

    @jobs << [delegate, args]
  end

  def set_worker_thread_callback &callback
    @callback = callback
  end

  def set_worker_thread_exception_callback &exception_callback
    @exception_callback = exception_callback
  end

  def start_processing
    @processing = true
    @pool = Array.new(@size) do |index|
      Thread.new do
        Thread.current[:id] = index

        catch(:stop_processing) do
          loop do
            if @jobs.length == 0
              sleep 0.2
              next
            end

            delegate, parameters = @jobs.pop
            result = nil

            begin
              result = delegate.call(parameters)
              @callback.call result unless @callback.nil?
            rescue StandardError => err
              @exception_callback.call err unless @exception_callback.nil?
            end
          end
        end
      end
    end
  end

  def stop_processing
    @processing = false
    @size.times do
      queue_worker_thread { throw :stop_processing }
    end
  end

  def wait_all &callback
    start_processing unless @processing

    stop_processing
    flush_pool

    callback.call unless callback.nil?
  end

  def flush_pool
    if @jobs.length > 0
      sleep 0.2
      flush_pool
    end

    @pool.each do |thread|
      thread.join
    end
  end
end

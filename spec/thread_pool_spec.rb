require_relative "spec_helper"
require_relative "../lib/ruby_thread_pool/ruby_thread_pool.rb"

describe RubyThreadPool do
  describe "#new" do
    it "should create a new instance with size = 10" do
      pool = RubyThreadPool.new 10
      expect(pool).to be_an_instance_of RubyThreadPool

      expect(pool.instance_variable_get(:@size)).to eq(10)
    end

    it "should create a new instance with size = 4" do
      pool = RubyThreadPool.new nil
      expect(pool).to be_an_instance_of RubyThreadPool
      expect(pool.instance_variable_get(:@size)).to eq(4)
    end

    it "should raise ArgumentError" do
      expect { RubyThreadPool.new "test" }.to raise_error(ArgumentError)
    end
  end

  describe "queue_worker_thread" do
    it "should enqueue a worker thread" do
      pool = RubyThreadPool.new 2

      str_value = "string"

      pool.queue_worker_thread do
        str_value;
      end

      job_queue = pool.instance_variable_get(:@jobs)

      expect(job_queue.length).to eq(1)

      delegate, parameters = job_queue.pop
      str_result = delegate.call()

      expect(str_result).to eq(str_value)
    end

    it "should raise an ArgumentError" do
      pool = RubyThreadPool.new 2
      expect { pool.queue_worker_thread "teste", nil }.to raise_error(ArgumentError)
    end

    it "should enqueue a worker thread with arguments" do
      pool = RubyThreadPool.new 2

      str_parameter = "string"

      pool.queue_worker_thread (str_parameter) do |str|
        str
      end

      job_queue = pool.instance_variable_get(:@jobs)
      expect(job_queue.length).to eq(1)

      delegate, parameters = job_queue.pop
      str_result = delegate.call(parameters)

      expect(str_result[0]).to eq(str_parameter)
    end
  end

  describe "set_worker_thread_callback" do
    it "should set the thread pool callback for worker threads" do
      pool = RubyThreadPool.new 2

      expect(pool.instance_variable_get(:@callback)).to be_nil

      pool.set_worker_thread_callback do |result|
        expect(result).to eq(str_test)
      end

      expect(pool.instance_variable_get(:@callback)).to be
    end

    it "should set the thread pool callback for worker threads to nil" do
      pool = RubyThreadPool.new 2

      expect(pool.instance_variable_get(:@callback)).to be_nil

      pool.set_worker_thread_callback

      expect(pool.instance_variable_get(:@callback)).to be_nil
    end
  end

  describe "set_worker_thread_exception_callback" do
    it "should set the thread pool exception callback for worker threads" do
      pool = RubyThreadPool.new 2

      expect(pool.instance_variable_get(:@exception_callback)).to be_nil

      pool.set_worker_thread_exception_callback do |result|
        expect(result).to eq(str_test)
      end

      expect(pool.instance_variable_get(:@exception_callback)).to be
    end

    it "should set the thread pool exception callback for worker threads to nil" do
      pool = RubyThreadPool.new 2

      expect(pool.instance_variable_get(:@exception_callback)).to be_nil

      pool.set_worker_thread_exception_callback

      expect(pool.instance_variable_get(:@exception_callback)).to be_nil
    end
  end

  describe "start_processing and stop processing" do
    it "should start/stop processing jobs queue" do
      pool = RubyThreadPool.new 2

      threads = 30

      threads.times do |index|
        pool.queue_worker_thread (index) do |i|
          i
        end
      end

      processing = pool.instance_variable_get(:@processing)
      job_queue = pool.instance_variable_get(:@jobs)
      expect(job_queue.length).to eq(threads)
      expect(processing).to be_falsey

      pool.start_processing

      sleep 0.5
      processing = pool.instance_variable_get(:@processing)
      job_queue = pool.instance_variable_get(:@jobs)
      expect(processing).to be_truthy
      expect(job_queue.length).to be < threads

      pool.stop_processing
      processing = pool.instance_variable_get(:@processing)
      job_queue = pool.instance_variable_get(:@jobs)
      expect(processing).to be_falsey
      current_jobs = job_queue.length

      threads.times do |index|
        pool.queue_worker_thread (index) do |i|
          i
        end
      end

      expect(job_queue.length).to be(threads + current_jobs)
    end
  end

  describe "wait_all" do
    it "should wait until all thread have finished" do
      pool = RubyThreadPool.new 2

      threads = 30

      threads.times do |index|
        pool.queue_worker_thread (index) do |i|
          i
        end
      end

      processing = pool.instance_variable_get(:@processing)
      job_queue = pool.instance_variable_get(:@jobs)
      expect(job_queue.length).to eq(threads)
      expect(processing).to be_falsey

      pool.wait_all

      processing = pool.instance_variable_get(:@processing)
      job_queue = pool.instance_variable_get(:@jobs)
      expect(job_queue.length).to eq(0)
      expect(processing).to be_falsey
    end

    it "should wait until all thread have finished and execute the given callback" do
      pool = RubyThreadPool.new 2

      threads = 30

      threads.times do |index|
        pool.queue_worker_thread (index) do |i|
          i
        end
      end

      processing = pool.instance_variable_get(:@processing)
      job_queue = pool.instance_variable_get(:@jobs)
      expect(job_queue.length).to eq(threads)
      expect(processing).to be_falsey

      callback_result = false

      pool.wait_all do
        callback_result = true
      end

      processing = pool.instance_variable_get(:@processing)
      job_queue = pool.instance_variable_get(:@jobs)
      expect(job_queue.length).to eq(0)
      expect(processing).to be_falsey
      expect(callback_result).to be
    end
  end
end

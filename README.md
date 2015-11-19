# ruby_thread_pool
Simple Thread pool implementation for ruby

### Bundler
Run the following commands to install gems:

```ruby
$ gem install bundler
$ bundle install
```
Running tests with `bundle exec rspec`:

```ruby
$ bundle exec rspec
```

## Code Examples

Create a simple thread pool with 5 threads

```ruby
require 'ruby_thread_pool'

pool = RubyThreadPool.new 5
```
To enqueue parameterless worker thread for async processing

```ruby
pool.queue_worker_thread do
  do_some_work()
  ...
  finish_work
end
```
This will add a job to the jobs queue (will not start processing)

To enqueue parameterized worker thread for async processing

```ruby
pool.queue_worker_thread(parameter1, parameter2) do |p1, p2|
  do_some_work_with_param(p1)
  puts p2
  ...
  finish_work
end
```
This will add another job to the jobs queue (will not start processing), this time with parameters

To set a callback to be called after the end of each worker thread
```ruby
pool.set_worker_thread_callback do |result|
  do_some_work_with_worker_thread_result(result)
end
```
This will set the worker_thread_callback but it will not start processing

Start/Stop processing worker threads queue
```ruby
pool.start_processing
pool.stop_processing
```
Those methods start or stop processing the jobs queue

To synchronously wait for all worker threads to finish use wait_all (this will start processing)
```ruby
pool.wait_all
```
To execute a block after ALL tasks have finished use  (this will start processing):
```ruby
pool.wait_all do
  do_finisher_work()
end
```
If a worker thread raise an Error you can use the set_worker_thread_exception_callback for managing the error
```ruby
pool.set_worker_thread_exception_callback do |err|
  do_some_logging_or_workaround(err)
end
```
###Full Code sample
```ruby
require 'ruby_thread_pool'

pool = RubyThreadPool.new 10

pool.set_worker_thread_callback do |result|
  do_some_work_with_worker_thread_result(result)
end

pool.set_worker_thread_exception_callback do |err|
  do_some_logging_or_workaround(err)
end

pool.queue_worker_thread do
  do_some_work()
  ...
  finish_work
end

pool.queue_worker_thread(parameter1, parameter2) do |p1, p2|
  do_some_work_with_param(p1)
  puts p2
  ...
  finish_work
end

pool.wait_all do
  do_finisher_work()
end
```

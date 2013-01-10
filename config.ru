require 'web'

$stdout.sync = true if development?

run Sinatra::Application
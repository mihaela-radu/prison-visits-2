require 'bundler'
Bundler.setup

require 'derailed_benchmarks'
require 'derailed_benchmarks/tasks'

DerailedBenchmarks.auth.user = -> { User.find_by!(email: "alan@example.com") }

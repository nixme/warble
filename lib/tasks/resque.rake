require 'resque/tasks'

# load our Rails environment (models, etc.) for every worker
task 'resque:setup' => :environment

class VCartRailtie < Rails::Generators::Base
  source_root(File.expand_path(File.dirname(__FILE__))
  def copy_initializer
    copy_file 'configatron_initializer.rb', 'config/initializers/configatron_initializer.rb'
  end
end

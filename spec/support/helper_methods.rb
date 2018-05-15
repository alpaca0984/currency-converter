module HelperMethods
  def load_json(name)
    file_path = File.expand_path(File.join(File.dirname(__FILE__), '../data', "#{name}.json"))
    File.read(file_path)
  end
end

RSpec.configure do |config|
  config.include HelperMethods
end

require 'yaml'
require 'config/raydee'
require 'services'
require 'widgets'

def load_services
  names = YAML::load(File.read(File.join(CONFIG_ROOT, "services", "installed.yml")))
  {
    :services => names[:services] ? strings_to_classes(names[:services]) : [],
    :widgets => names[:widgets] ? strings_to_classes(names[:widgets]) : [],
  }
end

def strings_to_classes strings
  strings.map {|string| Kernel.const_get string }
end
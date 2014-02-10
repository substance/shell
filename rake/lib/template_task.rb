require 'erb'

private
class ValuesBinding
  def initialize(values)
    @values = values;
  end

  def get_binding
    return binding
  end

  def method_missing(name)
    if (name == "values")
      return @values
    end

    return @values[name];
  end

end

private
class TemplateData

  attr_reader :_path, :_source, :_values, :_mode

  def initialize(name)
    @_path = name
    @_source = nil
    @_values = {}
    @_mode = 0644
  end

  def source(path)
    @_source = path
  end

  def path(path)
    @_path = path
  end

  def values(vals)
    @_values = vals
  end

  def mode(mode)
    @_mode = mode
  end

end

# Template Task
# -----
#
# Creates a task with the given name that creates a file
# using a ERB template file.
# The task is triggered whenever the source file has changed.
#
# Usage:
#
# ```
# template "out.txt" do
#   source "templates/mytemplate.erb"
#   mode 0644
# end
# ```

public
def template(name, &block)
  data = TemplateData.new(name)
  data.instance_eval(&block)
  template = File.read(data._source)
  renderer = ERB.new(template)
  values = ValuesBinding.new(data._values);

  # creating a task which is only triggered if the source file has changed
  file name => data._source do
    puts "Creating #{data._path} from #{data._source}"
    content = renderer.result(values.get_binding)
    File.open(data._path, 'w') {|f| f.write(content) }
    File.chmod(data._mode, data._path)
  end
end


def fixture_path(*elements)
  File.join(File.dirname(__FILE__), "fixtures", *elements)
end

def fixture_file_path(*elements)
  File.join("file://" + File.dirname(__FILE__), "fixtures", *elements)
end

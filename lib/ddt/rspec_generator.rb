class Ddt::RspecGenerator < Generator

  def generate(test_instance)
    output_buffer = "RSpec.describe #{test_instance.to_s} do\n"



    output_buffer << "end\n"
    output_buffer
  end

end
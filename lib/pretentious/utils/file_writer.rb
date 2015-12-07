module Pretentious
  # Utility function for saving pretentious test artifacts to a file.
  class FileWriter
    # options for the file writer
    def initialize(options = {})
      @spec_output_folder ||= (options[:spec_output_folder] || 'generated')
      @output_folder = options[:output_folder] || nil
    end

    def write(klass, result)
      output_folder = result[:generator].location(@output_folder)
      spec_output_folder = File.join(output_folder, @spec_output_folder)
      FileUtils.mkdir_p result[:generator].location(@output_folder)
      FileUtils.mkdir_p spec_output_folder
      result[:generator].helper(output_folder)
      filename = result[:generator].naming(spec_output_folder, klass)
      File.open(filename, 'w') { |f| f.write(result[:output]) }
      filename
    end

    def write_results(results)
      results.each do |g, result_per_generator|
        puts "#{g}:"
        result_per_generator.each do |klass, result|
          puts write(klass, result)
        end
      end
    end
  end
end

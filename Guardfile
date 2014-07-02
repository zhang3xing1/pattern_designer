# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/coffeescripts/.+\.coffee$})
  watch(%r{app/index\.html$}){
    FileUtils.cp('app/index.html', 'public')
  }
  watch(%r{app/styles/.+\.css$}){ |css_file|
    FileUtils.cp_r('app/styles', 'public/')
  }
  watch(%r{app/templates/.+\.html$}){ |html_file|
    puts html_file
    FileUtils.cp_r('app/templates/', 'public/scripts')
  }
end

guard 'coffeescript', :output => 'public/scripts', :source_map => true do
  watch(/^app\/coffeescripts\/(.*)\.coffee/)

  callback(:run_on_modifications_end) { 
  	puts '-'*100
    FileUtils.cp_r('app/coffeescripts', 'public/scripts')
    FileUtils.cp_r('app/styles', 'public/')
    FileUtils.cp('app/index.html', 'public')

    
    map_files = Dir.glob( File.join("**", "*.map") )
    unless map_files.empty?
      map_files.each do |file|
        text = File.read(file)
        puts = text.gsub("app/coffeescripts/#{File.basename(file,'.js.map')}.coffee", "coffeescripts/#{File.basename(file,'.js.map')}.coffee")
        File.open(file, "w") { |file| file << puts }
      end
    end
  }
end
 
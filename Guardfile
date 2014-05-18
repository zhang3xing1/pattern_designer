# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/scripts/.+\.js$})
  watch(%r{app/index\.html$})
  watch(%r{app/styles/.+\.css$})
end

guard 'coffeescript', :output => 'public/scripts', :source_map => true do
  watch(/^app\/coffeescripts\/(.*)\.coffee/)
  callback(:run_on_modifications_end) { 
  	puts '-'*100; 

  	FileUtils.cp_r('app/scripts', 'public/')
    FileUtils.cp_r('app/styles', 'public/')
    FileUtils.cp('app/index.html', 'public')
  }
  callback(:reload_end) { puts '+'*1000}
end
 
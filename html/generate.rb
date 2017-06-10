require 'erb'

RAW_TEMPLATE_STRING = <<~HTML
<html>
  <body>
    <h1><%= title %></h1>
      <video controls
             src="<%= video_src %>">
      </video>

      <a href="https://ruggeri.github.io/architecture_lecture">Back</a>
    </div>
  </body>
</html>
HTML

PAGES = [
  { title: "00 Basic Setup",
    video_src: "00_basic_setup.mov",
    fname: "00_basic_setup.html" },
  { title: "01 First AWS Box",
    video_src: "01_first_aws_box.mov",
    fname: "01_first_aws_box.html" },
  { title: "02 Basic Rails and Postgres",
    video_src: "02_basic_rails_and_postgres.mov",
    fname: "02_basic_rails_and_postgres.html" },
  { title: "03 Scale Up",
    video_src: "03_scale_up.mov",
    fname: "03_scale_up.html", },
  { title: "04 Scale Out",
    video_src: "04_scale_out.mov",
    fname: "04_scale_out.html", },
  { title: "05 Nginx",
    video_src: "05_nginx.mov",
    fname: "05_nginx.html", },
  { title: "06 Parallelism",
    video_src: "06_parallelism.mov",
    fname: "06_parallelism.html", },
  { title: "07 Threaded Server",
    video_src: "07_threaded_server.mov",
    fname: "07_threaded_server.html", },
  { title: "08 Select Server",
    video_src: "08_select_server.mov",
    fname: "08_select_server.html", },
  { title: "09 Locking",
    video_src: "09_locking.mov",
    fname: "09_locking.html", },
  { title: "10 Ruby Mutex",
    video_src: "10_ruby_mutex.mov",
    fname: "10_ruby_mutex.html", },
  { title: "11 C Lock",
    video_src: "11_c_lock.mov",
    fname: "11_c_lock.html", },
  { title: "12 Leader Demo",
    video_src: "12_leader_demo.mov",
    fname: "12_leader_demo.html", },
  { title: "13 Log Server Demo",
    video_src: "13_log_server_demo.mov",
    fname: "13_log_server_demo.html", },
  { title: "14 Log Client Demo",
    video_src: "14_log_client_demo.mov",
    fname: "14_log_client_demo.html", },
  { title: "15 Leader Follower Data Race",
    video_src: "15_leader_follower_data_race.mov",
    fname: "15_leader_follower_data_race.html", },
]

compiled_template = ERB.new(RAW_TEMPLATE_STRING)
PAGES.each do |page|
  title = page[:title]
  video_src = page[:video_src]
  content = compiled_template.result(binding)
  File.open(page[:fname], "w") { |f| f.puts content }
end

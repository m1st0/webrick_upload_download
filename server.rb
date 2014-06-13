require 'webrick'

root = File.expand_path './files/'
server = WEBrick::HTTPServer.new :Port => 80, :DocumentRoot => root

class Simple < WEBrick::HTTPServlet::AbstractServlet
  def do_GET request, response
    # status, content_type, body = do_stuff_with request

    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = 
	'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head profile="http://gmpg.org/xfn/11">
<title>
</title>
<body>
<h1>Now Sign EyeTech Software</h1>
	<form method="POST" enctype="multipart/form-data" action="/sign_windows_application.rb">
		<label>File:<input type="file" name="file" size="100"/></label> <br />
		<label>Password:<input type="password" name="password"/></label><br />
		<input type="submit" value="Go!" />
	</form>
</body>
</html>'
  end
end

class SignWinApp < WEBrick::HTTPServlet::AbstractServlet
  def do_POST request, response
    # status, content_type, body = do_stuff_with request
	# puts request.query
      filedata= request.query["file"]
	  # "filename" is not a name in the form so it means nothing
	  # myfilename = request.query["filename"]

	  # puts "myfilename=", filedata.filename
	  # puts "filedata=", filedata
	  
      f = File.open('./files/' + filedata.filename, "wb")
      f.write filedata
      f.close

      puts "Saved file OK"
	
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = 
"<html>
<head>
<script type=\"text/javascript\">
<!--
window.location='#{filedata.filename}'
//-->
</script>
</head>
<body>
Successfully Signed.
</body>
</html>"
  end
end

if __FILE__ == $0
	puts "Start server"
	trap 'INT' do server.shutdown end
	
	server.mount '/simple', Simple
	server.mount '/sign_windows_application.rb', SignWinApp

	server.start
end




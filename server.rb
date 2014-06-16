# Authors: Peter Hyatt and Maulik Mistry
# This code is provided "AS IS".  It just shows one way of using WebRICK 
# to receive an uploaded file, sign it, and then return that file.

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
<h1>Upload File with WebRICK</h1>
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

      # Implement the ability to upload a driver ZIP with INF and CAT files.
      #is_driver


      puts "Saved file OK"
      
      if is_driver.nil?
      	file_path = './files/' + filedata.filename
      else
      	# TODO: It's a driver so lets take care of the zipped driver package accordingly.
      end
      
      sign_tool_output = ''
	  if is_driver.nil?
		sign_tool_output = `signtool.exe sign /n "Company Name, Inc" /t http://timestamp.digicert.com "#{file_path}" 2>&1`
	  else
	    # "TODO: Unzip the catalog file and properly sign it then zip it back up."
	    # Since it is a driver, we need to sign the CAT file here, or embed/sign the SYS/INF individually.
	    sign_tool_output = `signtool.exe sign /ac "./Certificates/DigiCert High Assurance EV Root CA.crt" /n "Company Name, Inc" /t http://timestamp.digicert.com "#{file_path}" 2>&1`
	  end
	  sign_tool_output.gsub!("\n","<br />")
	  was_signed = 'Failed to sign the file.  See the output below.'
	  if sign_tool_output.include? "Successfully signed"
		was_signed = 'Successfully Signed.'
	  end
	  was_driver = ''
	  was_driver = 'It is a driver!' unless is_driver.nil?
	
    my_url = '[Your company url, reverse proxy which also blocks external requests.]'
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = 
"<html>
<head>
<script type=\"text/javascript\">
<!--
# Make sure Apache, etc is proxying this only to the internal developer network.

window.location = #{my_url}/files/#{filedata.filename}
//-->
</script>
</head>
<body>
  #{was_signed}  <br />
  #{was_driver}  <br />
-- signtool output --<br />
  #{sign_tool_output}
</body>
</html>"
  end
end

if __FILE__ == $0
	puts "Start server"
	trap 'INT' do server.shutdown end
	
	server.mount '/simple', Simple
	server.mount '/sign_windows_application', SignWinApp

	server.start
end




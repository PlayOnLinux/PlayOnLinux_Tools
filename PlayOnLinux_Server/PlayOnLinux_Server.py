#!/usr/bin/python
import SocketServer
import os
import shutil
import time
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import string
import sys
class MyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
	self.path = self.path.replace("..","")
	self.uri = string.split(self.path,'?')

        try:
	    if(self.uri[0] == '/V3_data/repository/get_file.php'):
		self.script = string.split(self.uri[1],'=')
		f = open("/tmp/POLServer/V3_data/scripts/" + self.script[1])
		self.send_response(200)
                self.send_header('Content-type','text/plain')
                self.end_headers()
                self.wfile.write(f.read())
                f.close()

	    else:
		if(self.uri[0] == '/'):
			self.send_response(200)
			self.send_header('Content-type','text/html')
			self.end_headers()
			self.wfile.write("PlayOnLinux Server is running !")
		else:
           		f = open("/tmp/POLServer/" + str(self.uri[0])) 
	                self.send_response(200)
           		self.send_header('Content-type','text/plain')
           		self.end_headers()
           		self.wfile.write(f.read())
           		f.close()
            return
                
        except IOError:
            self.send_error(404,'File Not Found: %s' % self.path)
     
		
    def do_POST(self):
        try:
            do_GET(self)
            
        except :
            pass

def idcat(filename):
	if(filename == "Other"):
		return 0
	if(filename == "Games"):
		return 1
	if(filename == "Accessories"):
		return 2
	if(filename == "Office"):
		return 3
	if(filename == "Internet"):
		return 4
	if(filename == "Multimedia"):	
		return 5
	if(filename == "Graphics"):
		return 6
	if(filename == "Development"):
		return 7
	if(filename == "Education"):
		return 8
	if(filename == "Patches"):
		return 9
	if(filename == "Testing"):
		return 10
	if(filename == "Functions"):
		return 100

	return -1

def main():
    try:
	PORT = 8050
        server = HTTPServer(('', PORT), MyHandler)
        print 'Ready to start the server ! Listening on port '+str(PORT)
        server.serve_forever()    
    except KeyboardInterrupt:
	print ''
        print 'Keyboard interrupt received, shutting down PlayOnLinux server.'
        server.socket.close()
    except:
	print ''
	print 'E. PlayOnLinux server is already running. Exiting'
	sys.exit()



print "Welcome to PlayOnLinux Script Server"
print ""

print " - Cleaning old temporary files"
try:
	shutil.rmtree("/tmp/POLServer")
except:
	pass

print " - Building server cache"
print ""
os.mkdir("/tmp/POLServer")
os.mkdir("/tmp/POLServer/V3_data")
os.mkdir("/tmp/POLServer/V3_data/repository")
os.mkdir("/tmp/POLServer/V3_data/scripts/")

try:
	os.chdir("PlayOnLinuxData")	
except:
	print("E. Unable to access to PlayOnLinuxData folder.")
	print("You can download a script database here :")
	print("http://repository.playonlinux.com/PlayOnLinux_Scripts.tar.gz")
	print("Then, place PlayOnLinuxData folder in the same directory than the script")
	print("")
	print("Error! Exiting.")
	sys.exit()

shutil.copy("VERSION","/tmp/POLServer/version2.php")

for filename in os.listdir('.'):
	if(os.path.isdir('./'+filename) and idcat(filename) != -1):
		print " + Adding "+filename+" ["+str(idcat(filename))+"]"
		for script in os.listdir('./'+filename):
			if(not os.path.isdir('./'+filename+"/"+script)):
				print " +   Caching script : "+script
				output_file = file('/tmp/POLServer/V3_data/repository/get_list.php', 'a') 
				output_file.write(str(idcat(filename))	+"/"+script+"/0/0/0\n")
				output_file.close()
				shutil.copy('./'+filename+"/"+script,"/tmp/POLServer/V3_data/scripts/"+script)
		print ""

os.chdir("/tmp/POLServer")
ofile = file('/tmp/POLServer/update_mark.txt', 'w') 
ofile.write(str(time.time()))
ofile.close()

ofile = file('/tmp/POLServer/check.txt', 'w') 
ofile.write('Ok')
ofile.close()


if __name__ == '__main__':
    main()



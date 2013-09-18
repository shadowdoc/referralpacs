# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# We need to protect our image files from people 
# URL hacking, so we need to have the controller handle each file
# This will use respond_to which requires knowlege of the "image/jpeg" MIME type.
Mime::Type.register("image/jpeg", :jpg)
mkdir download
# Add your -u username and -p parameter
sfdx force:mdapi:retrieve -s -r download -u  -p "Basiq Connector"
cd download
unzip unpackaged.zip
cp package.xml ../
cd ..
sfdx force:mdapi:convert --rootdir download
rm -r download
# This line will overwrite any changes made in originals of *.dup files. Be careful!
find . -name "*.dup" | while read f; do mv "$f" "${f//.dup/}"; done 
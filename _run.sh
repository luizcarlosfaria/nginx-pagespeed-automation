#!/bin/bash
echo '' && echo '' && echo '' && echo ''
echo '  ===================================================================='
echo '  |                                                                  |'
echo '  |         nginx-pagespeed Automation Automation Tool               |'
echo '  |                                                                  |'
echo '  |   https://github.com/docker-gallery/nginx-pagespeed              |'
echo '  |   https://github.com/docker-gallery/nginx-pagespeed-automation   |'
echo '  ===================================================================='
echo ''

if [ \( -f "./node_modules/ejs/ejs.js" \) -a  \( -f "./node_modules/is_js/is.js" \) -a  \( -f "./node_modules/linq/linq.js" \) ]
then
	echo "All packages found. Starting template engine..."
else
	echo "One or more required packages not found, trying to restore packages"
    npm install     
    echo "Starting template engine..."
fi
node ./index.js
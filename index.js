const ejs = require('ejs');
const fs = require('fs');
const Enumerable = require('linq');
const is  = require('is_js');


var data = JSON.parse(fs.readFileSync("./data.json", 'utf8'));

Enumerable.from(data.templates).forEach(function(currentTemplateConfig)
{
    console.log("-------------------------------------------------------------------------");
    console.log(currentTemplateConfig);
    var currentTemplateText = fs.readFileSync(currentTemplateConfig.Template, 'utf8');
    var outputContent = ejs.render(currentTemplateText, { data: data, fs: fs, Enumerable: Enumerable, is:is });
    
    fs.writeFileSync(currentTemplateConfig.Output, outputContent,'utf8', function(){});

    console.log("");
    console.log("Ok");
});
console.log("-------------------------------------------------------------------------");

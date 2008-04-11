// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function edit_new_title(o)
{
 title=o.value;
 if(title.length>5)
   $('new_topic').innerHTML=title;
 else
   $('new_topic').innerHTML="New Topic";
}
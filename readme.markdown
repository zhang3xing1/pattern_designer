1. line in and line out are not the same value;   -- ok

2. tool setting in box picking page;   --ok 

2.1 edit frame info in frame page and tool info in box picking page -- ok

6. csv review -- ok

7. implement tcp -- ok

3. temp mission data save, especially layer data; -- ok.

4. load pallet size infomation after getting detail info from multipack -- doing

8. redesign tool setting page as Alessio and Leonardo disscussed.

2.1 calculate the tool data by moving tcp to the center of box -- todo after discussion

5. animation when transitting -- transit is ok on mission index page, but not all pages. -- half





$(document).ready(function() {interval1 = setInterval(function(){get_popup()}, 1000)});
//$(document).ready(function() {interval2 = setInterval(function(){close_all()}, 1000)});


//function to get the value of the popup to open
function get_popup()
{
  $.ajax(
  {
    url: 'get?var=vi_popup_open&prog=pl_dd', 
    cache : true,
    async : false,
    success: function(data)
    {
      vi_open = data;
      popup_show()
    // console.log('get_popup')
    }
  });





UI Validator
1. Layer_name cannot contain blank char.

UI function:

1. Mission rename
2. Mission update
3. Mission load
4. Mission delete
5. Mission create
6. Mission edit, some validators.

7. sleepsheet height


PDL:

1. cross site request



Time delay problem:


inteval time should be considered. 

if the inteval time of two requesest is too short, the result could be wrong.
for exapmle: frame line in, frame line out.

in load mission data page, I try load 3 times load mission, worked in my macbook.


layer and used_layers connected by ulid 
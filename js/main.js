/*
Button Actions
*/
$(document).ready(function()  {
     $('#start-search-btn').click(function()  {
         $('#browser-body').hide('slow');
         $('#web-form').show('slow');
    });
});
$(document).ready(function()  {
     $('#new-search-btn').click(function()  {
         $('#results-div').hide('fast');
         $('#web-form').show('slow');
    });
});
$(document).ready(function()  {
     $('#new-search-from-results-btn').click(function()  {
         $('#browser-jumbotron').hide('fast');
         $('#web-form').show('slow');
    });
});
/*
Misc
*/
$(document).ready(function() { $("input").not("#start-search-btn").jqBootstrapValidation({preventSubmit: false}); } );
/*
Ad hoc solution to get the output from the php. Using Ajax from jQuery.
*/
$.ajax({
  type: "POST",
  url: 'php/twitter-feed.php',
  success: function(data) {
    $('#tweet').html(data);
  }
});

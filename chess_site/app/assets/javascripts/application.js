// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .

var state = 0;
var from;
var to;
$(document).ready(function(){
	$('.tile').click(function(){
		console.log(state);
		tile = $(this).find('.piece');
		if(state==0){
			from = $(this).attr('id');
			state=1;
		}
		else if(state==1){
			to = $(this).attr('id');
			console.log(from+' - '+to);
			state=2;
			$.get( "move/"+from+"/"+to, function( data ) {
				window.location = '';
				state=0;
			});
		}
		else if(state==2){
			alert('Please Wait');
		}
	});
})
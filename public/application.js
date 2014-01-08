$(".forms").hide(); // hide both forms at start
$("ul li a").click(function(){
	var idToShow = $(this).attr("href");
	$(idToShow).toggle().siblings(".forms").hide();
	return false;	// do not navigate to the beginning of form
});
$("#sign_up_confirmation").keyup(function(){
	if( $(this).val() != $("#sign_up_password").val() ) {
		$(this).addClass("error").next().text("Passwords don't match.");	// will go to span
	} else {
		$(this).removeClass("error").next().text("");				
	}
});

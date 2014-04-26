(function() {
	function pageload() {
		var submit = document.getElementById("bill");
		submit.onclick = getPictures;
	}
	
	function getPictures() {
		var submit = document.getElementById("bill");
		var name = submit.innerHTML;
		FB.api("/me", {fields: "id,name,picture"}, function(response)
		{

			FB.api(
					{
						method: 'fql.query',
						query: 'SELECT pic_big FROM profile WHERE id = response.id'
					},
					function(data1) {
						document.getElementById("first").src = data1[0].pic_big;
					}
			);

		});
	}
	
	window.onload = pageload;
})();
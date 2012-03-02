function facebookLogin() {
    FB.login(function(response) {
       console.log(response);
            if (response.status == "connected") {
                location.href = '/scripts'
            } else {
                console.log("error logging in");
            }
   });
}
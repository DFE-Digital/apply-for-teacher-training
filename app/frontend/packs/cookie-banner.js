// https://github.com/DFE-Digital/manage-courses-frontend/blob/master/app/webpacker/scripts/cookie-banner.js

function CookieMessage($module) {
  this.$module = $module;
}

CookieMessage.prototype.init = function() {
  var $module = this.$module;
  if (!$module) {
    return;
  }

  var $hasCookie = this.cookie("seen_cookie_message") === null;
  var $hasCookieMessage = $module && $hasCookie;

  if ($hasCookieMessage) {
    $module.style.display = "block";
    this.cookie("seen_cookie_message", "yes", { days: 28 });
  }
};

CookieMessage.prototype.cookie = function(name, value, options) {
  if (typeof value === "undefined") {
    return this.getCookie(name);
  }

  if (value === false || value === null) {
    return this.setCookie(name, "", { days: -1 });
  } else {
    return this.setCookie(name, value, options);
  }
};

CookieMessage.prototype.setCookie = function(name, value, options) {
  if (typeof options === "undefined") {
    options = {};
  }
  var cookieString = name + "=" + value + "; path=/";
  if (options.days) {
    var date = new Date();
    date.setTime(date.getTime() + options.days * 24 * 60 * 60 * 1000);
    cookieString = cookieString + "; expires=" + date.toGMTString();
  }
  if (document.location.protocol == "https:") {
    cookieString = cookieString + "; Secure";
  }
  document.cookie = cookieString;
};

CookieMessage.prototype.getCookie = function(name) {
  var nameEQ = name + "=";
  var cookies = document.cookie.split(";");
  for (var i = 0, len = cookies.length; i < len; i++) {
    var cookie = cookies[i];
    while (cookie.charAt(0) == " ") {
      cookie = cookie.substring(1, cookie.length);
    }
    if (cookie.indexOf(nameEQ) === 0) {
      return decodeURIComponent(cookie.substring(nameEQ.length));
    }
  }
  return null;
};

export default CookieMessage;


$(function () {

  wrtIframe: function (id, url, ancho, alto, scrolling, allowtransparency){
    $('<iframe src="' + url + '" width="' + ancho + '" height="' + alto + '" scrolling="' + scrolling + '" allowtransparency="' + allowtransparency + '" frameborder="0"></iframe>').appendTo('#'+id);
  },
  //sumoBioScript.wrtIframe('ifr_tw-tdsocial', 'http://platform.twitter.com/widgets/tweet_button.html?url=http://www.sumobilbao.com&amp;count=horizontal&amp;lang=es&amp;text=&amp;via=SumoBilbao', 110, 32, 'no', false);
  sumoBioScript.wrtIframe('ifr_fb-tdsocial', 'http://www.facebook.com/plugins/like.php?href=http://www.sumobilbao.com&amp;layout=button_count&amp;show_faces=false&amp;width=100&amp;action=like&amp;colorscheme=light&amp;height=100&amp;locale=es_ES ', 118, 32, 'no', 'false');

});


$(function (d,s,id) {
  var js,fjs=d.getElementsByTagName(s)[0];
  if(!d.getElementById(id)){js=d.createElement(s);
    js.id=id;js.src="//platform.twitter.com/widgets.js";
    fjs.parentNode.insertBefore(js,fjs);
  }
})(document,"script","twitter-wjs");

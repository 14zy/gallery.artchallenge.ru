require "json"

## Берем всю инфу по текущему языку из CouchDB
lang = "ru";
langDB = JSON.parse `curl -X GET http://178.62.133.139:5994/lang/#{lang}`


##Проходимся по всем 118 художникам
for n in 1..118

  allowEdit = ""

  ## Берем инфу по художнику из CouchDB
  painter = JSON.parse `curl -X GET http://178.62.133.139:5994/painters/#{n}`


  ## Обрабатываем немного
  description =  painter["bio"][lang].sub("<p>","")[0..150].gsub(/\s\w+\s*$/, '...')

  if painter["bio"]['ru'] == ""
    painter["bio"]['ru'] = "<p>Просим не гневаться, но биография этого художника временно отсутствует.</p><p>Ежели Вам известен хороший источник, будьте так любезны, добавьте биографию художника на сайт.</p>"
    allowEdit = %{<button id='editBtn' class='btn btn-clear'>Редактировать</button>}
  end

  painterName = langDB['painters'][painter['_id']]

  painterNations = []
  painter["nationality"].each do |nationality|
    painterNations.push(langDB['nation'][nationality])
  end

  painterGenres = []
  painter["genre"].each do |genre|
    painterGenres.push(langDB['genre'][genre])
  end

  # Генерим страницу
  html =  %{
    <!doctype html>
    <html lang="#{lang}">
      <head>
        <meta charset="utf-8">
        <meta name="description" content="#{ description }">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>#{ painterName } – биография и картины художника в жанре #{ painterGenres.join(', ') } – Art Challenge</title>
        <link rel="stylesheet" href="../css/bootstrap.min.css">
        <link rel="stylesheet" href="../css/jquery.fancybox.css">
        <link rel="stylesheet" href="../css/main.css">
        <link rel="stylesheet" href="../css/responsive.css">
        <link rel="stylesheet" href="../css/animate.min.css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

        <meta name="apple-itunes-app" content="app-id=1088982103">
        <link rel="alternate" hreflang="ru" href="http://gallery.artchallenge.ru/ru/#{ painter["id"] }.html"/>
        <link rel="alternate" hreflang="en" href="http://gallery.artchallenge.ru/en/#{ painter["id"] }.html"/>

      </head>
      <body>
        <!-- Yandex.Metrika counter -->
        <script type="text/javascript">
            (function (d, w, c) {
                (w[c] = w[c] || []).push(function() {
                    try {
                        w.yaCounter24594722 = new Ya.Metrika({
                            id:24594722,
                            clickmap:true,
                            trackLinks:true,
                            accurateTrackBounce:true,
                            webvisor:true
                        });
                    } catch(e) { }
                });

                var n = d.getElementsByTagName("script")[0],
                    s = d.createElement("script"),
                    f = function () { n.parentNode.insertBefore(s, n); };
                s.type = "text/javascript";
                s.async = true;
                s.src = "https://mc.yandex.ru/metrika/watch.js";

                if (w.opera == "[object Opera]") {
                    d.addEventListener("DOMContentLoaded", f, false);
                } else { f(); }
            })(document, window, "yandex_metrika_callbacks");
        </script>
        <noscript><div><img src="https://mc.yandex.ru/watch/24594722" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
        <!-- /Yandex.Metrika counter -->

        <section class="banner" role="banner">
          <header id="header">
            <div class="header-content clearfix">
              <a class="logo" href="http://gallery.artchallenge.ru/#{lang}/#{ painter["id"] }.html">#{ painterName }</a>
              <nav class="navigation" role="navigation">
                <ul class="primary-nav">
                  <li>
                    <a href="http://artchallenge.ru">Вернуться в Игру</a>
                  </li>
                  <li>
                    <a href="http://gallery.artchallenge.ru/index-ru.html">Обзор Художников</a>
                  </li>
                  <li>
                    <a href="http://artchallenge.ru/#introduction">Поддержать проект</a>
                  </li>
                </ul>
              </nav>
              <a href="#" class="nav-toggle">Меню<span></span>
              </a>
            </div>
          </header>
        </section>
        <section id="introduction" class="section introduction" style='padding-bottom:0'>
          <div class="container">
            <div class="row">
              <div class="col-md-4 col-sm-6">
                <div class="intro-content">
                  <img style='width:100%' src='../images/painters/#{ painter["id"] }.jpg'>
                </div>
              </div>
              <div class="col-md-5 col-sm-6">
                <div class="intro-content" id='text'>
                  #{ painter["bio"][lang] }
                  #{ allowEdit }
                </div>
                <div class="intro-content" id='editor' style='display:none;'>
                  <textarea id='txtBio' style='width: 450px; height: 500px'>#{ painter["bio"][lang] }</textarea>
                  <button id='saveBtn' class='btn btn-success'>Сохранить</button>
                </div>
              </div>
              <div class="col-md-3 col-sm-6">
                <div class="intro-content">
                <h4>Национальность</h4>
                #{ painterNations.join(', ') }
                <h4>Жанры</h4>
                #{ painterGenres.join(', ') }
                <h4>Годы жизни</h4>
                #{ painter["years"] }
                <h4>Википедия</h4>
                <a target='_blank' href='#{ painter["link"]['wikipedia'][lang] }'>Открыть страницу</a>
                </div>
              </div>
            </div>
          </div>
        </section>
        <section id="works" class="works section no-padding">
          <div class="container-fluid">
          <div class='text-center'><br><br><h3>Работы художника:</h3><br><br></div>
            <div class="row no-gutter">
  }


  ## Генерим галлерейку
  gallery = ""

  for i in 1..(painter["paintings"].count)
    

    index = i -1
    
    if painter["paintings"][index]["name"]["ru"] == ""
      painter["paintings"][index]["name"]["ru"] = "Неизвестно"
    end
    
    if painter["paintings"][index]["year"] == ""
      painter["paintings"][index]["year"] = "Неизвестно"
    end

    if painter["paintings"][index]["place"] == ""
      painter["paintings"][index]["place"] = "Неизвестно"
    end
    

    


      # gallery = gallery + %{
      #   <div class="col-lg-2 col-md-4 col-sm-4 work">
      #     <a rel='gallery-examples' href="http://artchallenge.me/painters/#{ painter["id"] }/#{i}.jpg" class="work-box">
      #       <img class='lazy' data-src="http://artchallenge.me/painters/#{ painter["id"] }/#{i}.jpg" alt="Картина #{ painterName }">
      #       <div class="overlay">
      #         <div class="overlay-caption">
      #           <p>
      #             <i class="fa fa-search-plus fa-2x"></i>
      #           </p>
      #         </div>
      #       </div>
      #     </a>
      #   </div>
      # }

      gallery = gallery + %{
        <div class='row'>
          <div class="col-md-2 col-sm-2">
          </div>

          <div class="col-md-7 col-sm-7 text-right">
            <a rel='gallery-examples' href="http://artchallenge.me/painters/#{ painter["id"] }/#{i}.jpg" class="work-box-no-css">
              <img style='max-width: 100%' class='lazy' data-src="http://artchallenge.me/painters/#{ painter["id"] }/#{i}.jpg" alt="Картина #{ painterName }">
            </a>
            <br><br><br><br>
          </div>
          
           

          <div class="col-md-3 col-sm-3" style='padding-left: 20px'>
            <h4 style='margin-top:0'>Название</h4>
            <text id='name-#{i}'>#{painter["paintings"][index]["name"]["ru"]} <i style='cursor: pointer' onclick="$('#name-#{i}').css('display', 'none'); $('#editName-#{i}').css('display', 'block');" class="fa fa-edit"></i></text>

            <div id='editName-#{i}' style='display:none'><textarea style='width: 90%' id='txtName-#{i}'>#{painter["paintings"][index]["name"]["ru"]}</textarea>
              <button style='margin-top: 0' id='saveName-#{i}' onclick='save("#{i}")' class='btn btn-xs btn-success'>Сохранить</button>
            </div>

            <br>
            <h4>Год создания</h4>

            <text id='year-#{i}'>#{painter["paintings"][index]["year"]} <i style='cursor: pointer' onclick="$('#year-#{i}').css('display', 'none'); $('#editYear-#{i}').css('display', 'block') " class="fa fa-edit"></i></text>

            <div id='editYear-#{i}' style='display:none'><textarea style='width: 90%' id='txtYear-#{i}'>#{painter["paintings"][index]["year"]}</textarea>
              <button style='margin-top: 0' id='saveYear-#{i}' onclick='save("#{i}")' class='btn btn-xs btn-success'>Сохранить</button>
            </div>

            <br>
            <h4>Находится</h4>
            <text id='location-#{i}'>#{painter["paintings"][index]["place"]} <i style='cursor: pointer' onclick="$('#location-#{i}').css('display', 'none'); $('#editLocation-#{i}').css('display', 'block') " class="fa fa-edit"></i></text>

            <div id='editLocation-#{i}' style='display:none'><textarea style='width: 90%' id='txtLocation-#{i}'>#{painter["paintings"][index]["place"]}</textarea>
              <button style='margin-top: 0' id='saveLocation-#{i}' onclick='save("#{i}")' class='btn btn-xs btn-success'>Сохранить</button>
            </div>
          </div>

        </div>
      }
  end


  html = html + gallery + %{
            </div>
          </div>
        </section>
        <footer id="contact" class="footer">
          <div class="container">
            <div class="col-md-4">
              <h4>Контакты</h4>
              <p>
                <a href='http://facebook.com/just14zy'>Рубен Бабаев</a> и <a href='http://www.facebook.com/plotkina.anna'>Анна Плоткина</a>
                <br>
                Email:
                <a href="mailto:info@artchallenge.ru">
                  info@artchallenge.ru
                </a>
              </p>
            </div>
            <div class="col-md-3">
              <h4>Социальные сети</h4>
              <ul class="footer-share">
                <li>
                  <a href="http://facebook.com/artchallenge.ru/">
                    <i class="fa fa-facebook"></i>
                  </a>
                </li>
                <li>
                  <a href="http://vk.com/art.challenge">
                    <i class="fa fa-vk"></i>
                  </a>
                </li>
                <li>
                  <a href="http://twitter.com/artchallenge_ru">
                    <i class="fa fa-twitter"></i>
                  </a>
                </li>
              </ul>
            </div>
            <div class="col-md-5">
              <p>© 2013-2016 Все права защищены.<br>
                Сделано с
                <i class="fa fa-heart pulse"></i>
                в
                <a href="#">Ростове-на-Дону</a>
              </p>
            </div>
          </div>
        </footer>
        

        <div class="modal fade" id='myModal' tabindex="-1" role="dialog" >
          <div class="modal-dialog ">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Закрыть"><span aria-hidden="true">&times;</span></button>
                  <h4 class="modal-title">Готово!</h4>
                </div>
              <div class="modal-body">
                Спасибо за добавление информации в базу Art Challenge!<br>Мы проверим ее и обязательно опубликуем в ближайшее время.
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-success" data-dismiss="modal">Ok</button>
              </div>
            </div>
          </div>
        </div>
        
        <script src="//yastatic.net/jquery/2.1.4/jquery.min.js" type="text/javascript"></script>
        
        <script src="../js/bootstrap.min.js"></script>
        <script src="../js/jquery.fancybox.pack.js"></script>
        <script src="http://js.nicedit.com/nicEdit-latest.js" type="text/javascript"></script>

        <script src="../js/jquery.lazy.min.js"></script>
        <script defer id="cid0020000126794164978" data-cfasync="false" async src="//st.chatango.com/js/gz/emb.js" style="width: 302px;height: 373px;">{"handle":"artchallenge","arch":"js","styles":{"a":"000000","b":100,"c":"FFFFFF","d":"FFFFFF","k":"000000","l":"000000","m":"000000","n":"FFFFFF","p":"10","q":"000000","r":100,"pos":"br","cv":1,"cvfnt":"'Helvetica Neue', Helvetica, Arial, sans-serif, sans-serif","cvbg":"000000","cvw":180,"cvh":30,"ticker":1,"fwtickm":1,"allowpm":0, "surl":0}}</script>
        <script>window.painterID = #{ painter["_id"] }</script>
        
        <script src="http://178.62.133.139:5994/_utils/script/json2.js"></script>
        <script src="http://178.62.133.139:5994/_utils/script/sha1.js"></script>
        <script src="http://178.62.133.139:5994/_utils/script/jquery.couch.js?0.11.0"></script>
        <script src="http://178.62.133.139:5994/_utils/script/jquery.dialog.js?0.11.0"></script>
            
        <script src="../js/main.js"></script>
      </body>
    </html>
  }
  
  




  ##Записываем в html файл
  File.open("../"+lang+"/"+painter["_id"] +".html", 'w+') do |file|
      file.write html
  end

end

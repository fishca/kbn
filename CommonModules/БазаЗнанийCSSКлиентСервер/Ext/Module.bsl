////////////////////////////////////////////////////////////////////////////////
// ПУБЛИЧНЫЕ МЕТОДЫ

Функция ПолучитьТаблицуСтилей() Экспорт
	
	Возврат СформироватьТаблицуСтилей();
	
КонецФункции

Функция ПолучитьТаблицуСтилейПоиска() Экспорт
	
	Возврат 
	"<style type='text/css'>
	|/*
	|Version: 1.0.1
	|Author Aniskov A.
	|*/
	|
	|" + ТаблицаСтилей_common() + "
	|
	|/*СТИЛИ ДЛЯ ОФОРМЛЕНИЯ ПОИСКА*/
	|.main {overflow:auto; margin-bottom:15px}
	|.presentation {font-size: 12px; padding: 2px 0 0 0; border-top:1px dashed #666;}
    |.textPortion {font-size: 11px; padding: 2px 0 5px 0;}
    |.bold {font-weight: bold;}
	|</style>";
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ФОРМИРОВАНИЕ ТАБЛИЦЫ СТИЛЕЙ CSS

Функция СформироватьТаблицуСтилей()
	СтрокаТаблицыСтилей = 
	"<style type='text/css'>
	|/*
	|PTB wiki theme
	|Version: 1.1.1
	|Author Siraev I., Aniskov A.
	|*/
	|
	|" + ТаблицаСтилей_common() + "
	|
	|" + ТаблицаСтилей_menu() + "
	|
	|" + ТаблицаСтилей_content_footer() + "
	|
	|" + ТаблицаСтилей_page_path() + "
	|
	|" + ТаблицаСтилей_categories() + "
	|
	|" + ТаблицаСтилей_articles() + "
	|
	|" + ТаблицаСтилей_news() + "
	|
	|" + ТаблицаСтилей_article() + "
	|
	|" + ТаблицаСтилей_news_item() + "
	|
	|" + ТаблицаСтилей_user() + "
	|
	|" + ТаблицаСтилей_command_panel() + "
	|
	|" + ТаблицаСтилей_tags() + "
	|
	|" + ТаблицаСтилей_comments() + "
	|
	|/*АСУП*/
	|.pictureblock {float:none; text-align:center; font-family: sans-serif; font-size:11px; margin:0; padding:2px; background-color:#ffffff;}
	|.pictureblock a img {background-color:#ffffff; border:0; padding:0; margin:0;}
	|.tableblock {border:none; background:#ffffff; margin:0; text-align:center;}
	|.t_text {font-size:9px}
	|.marker {background-color:#ffff00}
	|
	|/*ДОПОЛНИТЕЛЬНО*/
	|</style>";
	
	Возврат СтрокаТаблицыСтилей;
КонецФункции

Функция ТаблицаСтилей_common()
	
	// font-family:Arial,Helvetica,sans-serif;
	Возврат 
	"/*General styles*/
	|html {height:100%; width:100%;}
	|body {background:#fff; font-family:Tahoma, Arial, sans-serif; font-size:13px; min-width:600px; margin:0;}
	|a {color:#0066bb; text-decoration:none;}
	|a:hover {color:#00437a; text-decoration:none;}
	|abbr {border-bottom:1px dotted #666; cursor:help;}
	|
	|.flt_l {float:left;}
	|.flt_r {float:right;}";
	
КонецФункции

Функция ТаблицаСтилей_menu()
	Возврат
	"/*МЕНЮ*/
	|.menu {margin: 0 25px 10px 25px; padding: 5px 5px 5px 0; border:1px solid #a4d8ff;}
	|.menu img {line-height:40px; float:left;}
	|.menu li {display:inline; padding-bottom:5px;}";
КонецФункции

Функция ТаблицаСтилей_content_footer()
	Возврат
	"/*КОНТЕНТ ОБЕРТКА*/
	|.content_main {padding: 10px 15px; overflow:hidden;}
	|.content_main h1 {font-size:20px; border-bottom: 1px solid #AAAAAA; padding-bottom:3px; margin-bottom: 15px;}
	|.content_main h2 {font-size:17px; border-bottom: 1px solid #AAAAAA; padding-bottom:3px; margin: 15px 0;}
	|.content_main h3 h4 h5{font-size:13px; border-bottom: 1px solid #AAAAAA; padding-bottom:3px; margin: 15px 0;}
	|.content_main h6 {font-size:13px; border-bottom: 1px solid #AAAAAA; padding-bottom:3px; margin-bottom: 5px;}
	|.content_main ul {list-style-type: disc; margin-left:20px;}
	|
	|#footer {padding: 10px 15px;}
	|
	|/*НАВИГАЦИЯ В КОНТЕНТЕ*/
	|.content_menu_header {float:right; position:absolute;}";
КонецФункции

Функция ТаблицаСтилей_page_path()
	Возврат
	"/*ПУТЬ К СТРАНИЦЕ*/
	|#page_path {font-size:12px; color:#000; line-height:20px; border-bottom:1px dotted #666; margin-bottom:5px; padding-bottom:2px;} 
	|#page_path img {color:#0066bb; height:16px; margin: 0 2px 0 0;}";
КонецФункции

Функция ТаблицаСтилей_categories()
	Возврат  
	"/*СПИСОК КАТЕГОРИЙ*/
	|#categories {margin-bottom:10px;}
	|#categories table {border-collapse:separate;}
	|#categories table tr {vertical-align:top;}
	|#categories table td {padding:0 5px; width:1%;}
	|#categories h1 {font-size:18px; font-weight:400; border-bottom:1px solid #9DB6C9; padding:3px; margin:0;}
	|#categories h1 a {color:#26587E; text-decoration:none;}
	|
	|/*ОПИСАНИЕ КАТЕГОРИИ*/
	|.category {padding:8px 5px; margin:8px 0 0 0; border:1px solid #9DB6C9; border-radius:5px; background-color:#F7FBFF;}
	|.category .title {color:#0066bb; font-size:14px; border:0;}
	|.category .title img {margin: 0 5px 0 0; width:16px; height:16px;}
	|.category .title h2 {padding:0 0 0 2px; margin: 0 0 2px 21px; font-size:13px; border:0; font-weight:400;}
	|.category .title h2 a {color:#26587e; text-decoration:none;}
	|.category .title h2 a:hover {color:#4296d6;}
	|.category .title .stat {color:#687580; font-size:11px; border:1px solid #9DB6C9; border-radius:50%; padding:1px 5px; text-align:center;}
	|.category .title .stat img {width:16px; height:16px;}
	|.category .title .stat .text {display:table-cell; vertical-align:middle;}
	|.category .info {color:#666; font-size:11px; text-align:justify; margin:5px 0 0 0;}";	
КонецФункции

Функция ТаблицаСтилей_articles()
	Возврат
	"/*СТАТЬИ*/
	|#articles {padding:0 0 10px 0; margin: 0 0 10px 0; * width:100%;}
	|#articles table {border-collapse:separate;}
	|#articles table tr {vertical-align:top;}
	|#articles table td {padding:0 5px;}
	|#articles h1 {color:#3f5e20; font-size:16px; border-bottom:1px solid #3f5e20; padding:5px 3px; margin:0; font-weight:400;}
	|#articles h1 a {color:#3f5e20;}
	|#articles h1 a:hover {color:#00b907;}
	|
	|/*СТАТЬЯ (КРАТКО)*/
	|.article_s {border-bottom:1px dashed #669933; padding:5px;}
	|.article_s:hover {background-color:#E4FFCB}
	|.article_s .head {padding-right:2px;}
	|.article_s .head h2 {padding:0 0 0 2px; margin: 0 0 4px 0; font-size:13px; border:0;}
	|.article_s .head h2 a {color:#3f5e20; font-weight:400; text-decoration:none; font-size:13px; line-height:18px;}
	|.article_s .head h2 a:hover {color:#00b907;}
	|.article_s .head .info {padding:0 0 0 2px; color:#666; font-weight:normal; font-size:11px; text-align:justify;}
	|.article_s .head .stat {float:right; display:inline;}
	|.article_s .head .stat img {float:left; height:16px; width:16px; margin:0 3px;}
	|.article_s .head .stat .text {display:table-cell; vertical-align:middle; font-size:11px; float:left; margin:0; line-height:16px;}
	|.article_s .text {color:#333; font-size:13px; text-align:justify; margin:3px 0 8px 0; padding:2px; line-height:18px;}";
КонецФункции

Функция ТаблицаСтилей_news()
	Возврат
	"/*НОВОСТНАЯ ЛЕНТА*/
	|#news {margin-bottom:10px;}
	|#news h1 {font-size:18px; font-weight:400; color:#ca2d2d; border-bottom:1px solid #ca2d2d; padding:3px; margin:0 0 8px 0;}
	|#news h1 a {color:#ca2d2d; text-decoration:none;}
	|#news h1 a:hover {color:#ff1818;}
	|
	|.news {padding:0 0 5px 8px; line-height:15px;}
	|.news .descr {display:table-cell; font-size:13px; vertical-align:middle; padding-right:3px;}
	|.news .descr img {width:16px; height:16px; margin:0 5px 0 0;}
	|.news .descr a {color:#ca2d2d;}
	|.news .descr a:hover {color:#ff1818;}
	|.news .info {color:#666; font-size:11px; display:table-cell; vertical-align:middle;}
	|.news .text {margin:3px 0 8px 0; color:#333; font-size:13px; text-align:justify; padding:2px 2px 5px 2px; line-height:18px; border-bottom:1px dashed #666;}";
КонецФункции

Функция ТаблицаСтилей_article()
	Возврат
	"/*СТАТЬЯ (ПОЛНОСТЬЮ)*/
	|.article {border:1px solid #c5f8ac; border-radius:5px; padding:5px 5px 10px 5px; margin-bottom:15px;}
	|
	|.article h1 {color:#669933; font-size:15px; font-weight:400; padding:3px; border-bottom:1px solid #ccc; margin:8px 0; height:22px;}
	|.article .info {border:1px solid #9DB6C9; border-radius:5px; padding:5px; background-color:#F7FBFF; margin-bottom:6px;}
	|.article .text {font-size:13px; margin:0 5px 15px 5px; line-height:1.2}
	|.article .text a {text-decoration:none;}
	|.article .text a:hover {text-decoration:underline;}
	|.article .text p {margin:5px 0 2px 0}
	|.article .text ul {margin:5px 0 2px 0; padding-left:10px; list-style-position:inside;}
	|.article .text li {}
	|.article .text h1 {color:#000; font-size:20px; border-bottom: 1px solid #AAAAAA; padding-bottom:3px; margin-bottom: 15px;}
	|.article .text h2 h3 {color:#000; font-size:17px; border-bottom: 1px solid #AAAAAA; padding-bottom:3px; margin: 12px 0;}
	|.article .text h4 h5 h6 {color:#000; font-size:14px; border-bottom: 1px solid #AAAAAA; padding-bottom:3px; margin: 10px 0;}
	|
	|.article .contents {background: #fff; border:1px solid #D5E2F1; border-radius:5px; padding:5px; width:350px; margin-bottom:10px;}
	|.article .contents ul {padding: 0 0 0 25px;}
	|.article .contents li {padding: 3px 0 3px 0;}
	|
	|.article .sup {font-size:9px; vertical-align:super;}
	|.article .references {margin-bottom:15px;}
	|.article .references li {list-style-type:none;}
	|
	|.article .tableblock {clear:both;}
	|
	|#article_tags {border:1px solid #ffa300; padding:3px; margin:0;}
	|#article_tags ul {display:inline; list-style-type:none; padding:0; margin:0;}
	|#article_tags li {display:inline; margin:0 2px;}";
КонецФункции

Функция ТаблицаСтилей_news_item()
	Возврат
	"/*НОВОСТЬ*/
	|#newsitem {border:1px solid #cea9a9; border-radius:5px; padding:5px 5px 10px 5px; margin-bottom:15px;}
	|
	|#newsitem h1 {font-size:18px; font-weight:400; color:#ca2d2d; border-bottom:1px solid #ca2d2d; padding:3px; margin:0 0 8px 0;}
	|#newsitem .info {border:1px solid #9db6c9; border-radius:5px; padding:5px; background-color:#f7fbff; margin-bottom:6px;}
	|#newsitem .text {font-size:13px; margin:0 5px 15px 5px; line-height:1.2}
	|#newsitem .text a {text-decoration:none;}
	|#newsitem .text a:hover {text-decoration:underline;}";
КонецФункции

Функция ТаблицаСтилей_user()
	Возврат 
	"/*ПРОФИЛЬ*/
	|.user {padding:10px 0; background-color:#f1f5f8; margin-bottom:10px; border:1px solid #d5e2f1; border-radius:5px;}
	|.user_head img {width:42px; height:42px; float:left; margin:0 5px;}
	|.user_head h1 {margin:0 0 5px 55px; font-size:16px; border:0; font-weight:normal;}
	|.user_head h1 a {color:#0066bb; text-decoration:none; font-weight:400;}
	|
	|#panel_button ul {list-style-type:none; margin:0; padding:0;}
	|#panel_button li {display:inline; padding:2px 5px; margin-left:7px; border:1px solid #c5f8ac; background-color:#e5ffd8; border-radius:5px; border-bottom-left-radius:0; border-bottom-right-radius:0;}
	|#panel_button li a {font-weight:normal; text-decoration:none; color:#000;}
	|
	|#panel_content {margin:2px 0; padding:8px 5px; border:1px solid #c5f8ac; border-radius:5px;}";
	
КонецФункции

Функция ТаблицаСтилей_command_panel()
	Возврат
	"/*КОМАНДНАЯ ПАНЕЛЬ*/
	|#command_panel {display:inline; border:0; margin:2px 0 0 5px; font-size:12px; font-weight:normal; color:#ccc;}
	|#command_panel ul {display:inline; list-style-type:none; padding:0; margin:0;}
	|#command_panel li {float:left; display:table-cell; vertical-align:middle; padding:0 2px;}
	|#command_panel img {border:0; margin:0 5px; height:16px; vertical-align:middle;}
	|#command_panel a {text-decoration:none; padding:2px 0;}
	|
	|#command_panel .first_page {font-size:12px; padding:0 2px 0 6px; border-left:1px solid #ccc;}
	|#command_panel .prev_page {font-size:12px; padding:0;}
	|#command_panel .next_page {font-size:12px; padding:0;}
	|#command_panel .page_info {font-size:12px; padding:0 2px 0 4px; color:#26587e;}";
КонецФункции

Функция ТаблицаСтилей_tags()
	Возврат
	"/*ОБЛАКО ТЕГОВ*/
	|#tags {font-size: 13px; border-bottom:1px dashed #e4f2fb; border-top:1px dashed #e4f2fb; margin-bottom:10px; padding:0 5px; min-height:20px; * width:100%;}
	|#tags ul {text-align:center; padding:1px 10px 1px 10px;}	
	|#tags li {display:inline; vertical-align:middle; list-style-type:none; margin: 0 3px;}
	|#tags li a {color:#0066bb; text-decoration:none;}
	|#tags li a:hover {color:#84adff;}
	|#tags .tag1 {font-size:80%;}
	|#tags .tag2 {font-size:90%;}
	|#tags .tag3 {font-size:105%;}
	|#tags .tag4 {font-size:120%;}
	|#tags .tag5 {font-size:140%;}";
КонецФункции

Функция ТаблицаСтилей_comments()
	Возврат
	"/*КОММЕНТАРИИ*/
	|#comments {border-bottom:1px solid #aaa; margin: 10px 0 0 0; line-height:18px; verical-align:middle;}
	|#comments .h1 {color:#555; font-size:15px; margin:10px 0 0 0; padding:5px 0;}
	|#comments_panel {float:right; padding:2px 5px; font-size:12px; font-weight:normal;}
	|#comments_panel a {color:#0066bb; text-decoration:none; border-left:1px solid #666; border-right:1px solid #666; padding: 0 5px;}
	|.comment {margin:0 0 2px 0; padding-top:8px; border-top:1px solid #aaa;}
	|.comment img {width:36px; height:36px; float:left; margin-right:5px;}
	|.comment h1 {margin:0 0 2px 45px; padding:0; font-size:14px; font-weight:400; border:0; height:18px;}
	|.comment h1 a {color:#0066bb; text-decoration:none;}
	|.comment_body {margin:2px 0 8px 45px;}
	|.comment_body_text {margin:0;}
	|.comment_body_text p {margin:3px 0 2px 0;}
	|.comment_body_panel {margin:5px 0 0px 0; color:#666; font-size:11px;}
	|.comment_body_panel a {color:#666; font-size:11px;}";
КонецФункции

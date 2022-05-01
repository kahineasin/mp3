<!DOCTYPE HTML>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="utf-8" />
    <%@  language="vbscript" codepage="65001" %>
    <%        
dim pageTitle
pageTitle="some mp3"
        if Request.QueryString("level")="" then
            pageTitle="我的翻唱"
        elseif Request.QueryString("level")="k" then
            pageTitle="k歌伴奏"
        elseif Request.QueryString("level")="v" then
            pageTitle="视频"
        end if
         %>
    <title><%Response.Write pageTitle %></title>
    <!--<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimum-scale=0.46, maximum-scale=0.46">-->
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimum-scale=1.0, maximum-scale=1.0" />
    <!--<meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta content="telephone=no" name="format-detection">-->

    <script  type="text/JavaScript"  src="script/jquery-1.7.1.min.js" ></script>
<!--    <script type="text/javascript" src="http://sellgirl.com/Content/js/sellgirl/EleResize.js"></script>
    <script type="text/javascript" src="http://sellgirl.com/Content/js/sellgirl/sellgirl.js"></script>-->
    
    <!--如果不播放flv文件,可以去掉flv.min.js引用-->
    <script type="text/javascript" src="https://html.sellgirl.com/js/flv.min.js"></script>
<!--    <script type="text/javascript" src="https://kahineasin.github.io/htmlAll/js/EleResize.js"></script>
    <script type="text/javascript" src="https://kahineasin.github.io/htmlAll/js/sellgirl.js"></script>
    <script type="text/javascript" src="https://kahineasin.github.io/htmlAll/js/pfUtil.js"></script>-->
    <script type="text/javascript" src="https://html.sellgirl.com/js/EleResize.js"></script>
    <script type="text/javascript" src="https://html.sellgirl.com/js/sellgirl.js"></script>
    <script type="text/javascript" src="https://html.sellgirl.com/js/pfUtil.js"></script>
    <!--<script  type="text/JavaScript"  src="script/pfUtil.js" ></script>-->
    <!--<script type="text/javascript" src="http://192.168.1.52:19005/Content/js/sellgirl/EleResize.js"></script>
    <script type="text/javascript" src="http://192.168.1.52:19005/Content/js/sellgirl/sellgirl.js"></script>-->
    <script type="text/javascript">
        $(function() {
            //背景图片
//        sellgirl.backgroundImg(document.body, 'img/web_sasha_1920x1080_02.jpg', { w: 2300, h: 2300, s: { x: 0, y: 1150 }, e: { x: 2300, y: 1150} }, { thumbnail: 'img/web_sasha_thumbnail.jpg' });
//            sellgirl.backgroundImg(document.body, 'img/web_sasha_1920x1080_02.jpg', { w: 2300, h: 2300, s: { x: 0, y: 1150 }, e: { x: 2300, y: 1150} }, null, { thumbnail: 'img/web_sasha_thumbnail.jpg' });
            sellgirl.backgroundImg(document.body, 'img/web_sasha_1920x1080_02.jpg', { w: 2300, h: 2300, s: { x: 0, y: 1150 }, e: { x: 2300, y: 1150} },{opacity:0.5}, { thumbnail: 'img/web_sasha_thumbnail.jpg' });
        });
    </script>

</head>
<body style="margin: 0px;">
    <div style="position:absolute;right:0px;top:0px;z-index:3"><a href="category.html">分类目录</a></div>
    <!--<canvas id="h5Image" style="position:absolute;z-index:2;"></canvas>-->
    <%        
dim mp3FolderPath      
dim lrcFolderPath     
        if Request.QueryString("level")="" then
            mp3FolderPath="./mp3/"
            lrcFolderPath="./lrc/"
        else
            mp3FolderPath="./mp3/"&Request.QueryString("level")+"/"
            lrcFolderPath="./lrc/"&Request.QueryString("level")+"/"
        end if
         %>
    <!--#include file="sellgirl_mediaPlayer.asp"-->
</body>
</html>

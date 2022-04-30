<!--HTML5播放器,自动读取变量mp3FolderPath这个文件夹下的文件,自动识别是video还是audio,20180117-->
<link rel="stylesheet" type="text/css" href="./css/sellgirl_player_list.css">

<script type="text/javascript" src="script/html5media.min.js"></script>

<div class="audioContainer">
    <div class="videoLayer">
    </div>
    <div class="sellgirl_player_list_container">
        <div class="sellgirl_player_list">
            <div class="sellgirl_player_list_toolbar">
                <!-- <a style="clear: both" href="javascript:;"  onclick="return nextPlayMode(this)">&lt;Order Repeat&gt;</a> -->
                <a href="javascript:;" onclick="return nextPlayMode(this)">&lt;随机播放&gt;</a> <a href="javascript:;"
                    onclick="return playNext(this)">&lt;下一首&gt;</a> <a id="selectSongBtn" href="javascript:;"
                        onclick="return selectSong(this)">&lt;选歌...&gt;</a> <a href="javascript:;" id="nexLrcModeBtn"
                            onclick="return nextLrcMode(this)">&lt;单行歌词...&gt;</a>
            </div>
            <hr />
            <div class="sellgirl_player_list_top">
                <%
Set Fso = CreateObject("Scripting.FileSystemObject")
Set X = Fso.GetFolder(Server.mapPath(mp3FolderPath))
 int i
                        

function getFileName(str)
	dim regEx
	set regEx=New RegExp
	regEx.Pattern="(.+)\.[^\.]+$"
	regEx.Ignorecase=True
	regEx.Global=True
	getFileName=regEx.Replace(str,"$1")
End function

function containFileName(names,fname)
    Dim r
    Dim myArr1
    myArr1=Split(names,",")
    r=0
    for each F in myArr1
        If F=fname Then
            r=1
        End If
    Next
    containFileName=r
End function

Dim strFiles
Dim tmpFileName
strFiles=""
tmpFileName=""
                
for each F in X.files
    tmpFileName=getFileName(F.Name)
    If strFiles="" Then
    Else
        strFiles=strFiles&","
    End If
    If containFileName(strFiles,tmpFileName)=1 Then
    Else
        strFiles=strFiles&tmpFileName
    End If
Next
                
Dim arrFiles
arrFiles=Split(strFiles,",")

i=0

for each n in arrFiles
    tmpFileName=""
    for each F in X.files
        If InStr(F.Name,n&".")>0 Then
            If tmpFileName="" Then
            Else
                tmpFileName=tmpFileName&","
            End If
            tmpFileName=tmpFileName&Replace(F.Name,n&".","")
        End If
    Next
    Response.Write "<a onclick='liClick(this)' href='#' src='"&mp3FolderPath&n&"' sgIdx='"&i&"' sgFmts='"&tmpFileName&"'>"&Replace(n,"_"," ")&"</a>"
    i=i+1
Next

                %>
            </div>
        </div>
    </div>
    <br />
    <div class="sellgirl_player_lrcContainer">
        <ul id="lrclist" class="sellgirl_player_lrc">
            <!-- 保证歌词在正中间 -->
        </ul>
        <!-- <p>无歌词</p> -->
    </div>
</div>

<script type="text/javascript">
    //缓存
    function sNumber(num, key, defaultNum) {
        if (defaultNum === undefined || undefined === null) { defaultNum = 0; }
        if (num !== null && num !== undefined) {
            localStorage.setItem(key, num.toString());
        }
        return localStorage.getItem(key) == null || localStorage.getItem(key) == 'undefined' ? defaultNum : parseInt(localStorage.getItem(key));
    }
    function sCurIdx(curIdx) {
        return sNumber(curIdx, 'sellgirl_mediaPlayer_curIdx');
    }
    function sPlayMode(playMode) {
        //return sNumber(playMode, 'sellgirl_mediaPlayer_playMode');
        return sNumber(playMode, 'sellgirl_mediaPlayer_playMode', 2); //默认随机播放
    }
    function sLrcMode(lrcMode) {
        return sNumber(lrcMode, 'sellgirl_mediaLrcer_lrcMode', 1);
    }

    var medias = {};
    var curIdx = sCurIdx();
    var playMode = sPlayMode();
    var lrcMode = sLrcMode();

    var lrcJSONCache = {};
    var lrcTimeCache = {}; //歌词对应的时间数组--benjamin20191125
    //var lrcTime = [];//歌词对应的时间数组--benjamin20191125
    // var lrcTitle = '';//歌词标题
    var randomPlayList = [];
    var randomPlayContainer = null;

    function getPlayLis() {//获得播放列表li
        return document.getElementsByClassName('sellgirl_player_list_top')[0].children;
    }

    if (getPlayLis().length - 1 < curIdx) { curIdx = sCurIdx(0); } //当服务器中删除了视频文件时,当前idx可能已经太大了

    function setDefaultBg(oldSrc) {
        var lis = getPlayLis();
        for (var i = 0; i < lis.length; i++) {
            if (decodeURIComponent('./' + oldSrc.replace(window.location.href.replace(/[^\/]*$/, ''), '')) == lis[i].attributes.getNamedItem('src').nodeValue + '.' + lis[i].attributes.getNamedItem('sgFmts').nodeValue.split(',')[0]) {
                lis[i].style.backgroundColor = ''; // 'white';//如果加了白色,会挡住 a:hover时的背景色
            }
        }

    }
    function srcIsVideo(src) {
        var lcSrc = src.toLowerCase();
        //var formats = ['.mp4', '.ogg', '.mkv'];
        var formats = ['mp4', 'mkv']; //改为多source后--20180728
        for (var i = 0; i < formats.length; i++) {
            if (lcSrc.indexOf(formats[i]) > -1) { return true; }
        }
        return false;
    }
    function mediaIsStopped(media) {
        return media.ended || media.paused;
    }
    function createVideo(src, isVideo) {
        isVideo = (isVideo !== false); //默认true
        var oVideo = document.createElement(isVideo ? "video" : "audio");
        oVideo.autoplay = 'autoplay';
        oVideo.controls = 'controls';
        oVideo.className = 'classAudio';
        oVideo.autobuffer = 'autobuffer';
        //oVideo.src = src;
        oVideo.addEventListener('ended', function() {
            playNext();
        });
        return oVideo;
    }
    function liClick(li) {

        var idx = parseInt(li.attributes.getNamedItem('sgIdx').nodeValue);
        sCurIdx(idx);
        if (idx === curIdx && medias[idx]) {//当重播时
            if (!medias[idx].ended) { medias[idx].currentTime = 0; }
            medias[idx].play();
            return;
        }

        var aus = document.getElementsByClassName('classAudio');
        var videoLayer = document.getElementsByClassName('videoLayer')[0];
        if (aus && aus.length > 0) {
            //setDefaultBg(aus[0].src);//iphone不支持此属性currentSrc
            setDefaultBg(aus[0].childNodes[0].src); //iphone不支持此属性currentSrc.改为多个source之后要用第一个子节点的url去找当前播放地址

            if (!mediaIsStopped(aus[0])) { aus[0].pause(); }
            if (!medias[curIdx]) { medias[curIdx] = aus[0]; }
            videoLayer.removeChild(aus[0]);
        }

        var src = li.attributes.getNamedItem('src').nodeValue;
        //debugger;
        //var isVideo = srcIsVideo(src);
        var isVideo = srcIsVideo(li.attributes.getNamedItem('sgFmts').nodeValue); //改为多source之后--20180728
        if (!medias[idx]) {
            medias[idx] = createVideo(src, isVideo);
        } else {
            if (isVideo) {//iphone上,如果不重新load的话,有时切换到不同格式时就会显示不了video的图像,没办法先加这句;华为手机上,即使load了也没用,视频直接停了,所以干脆重新创建element
                var oldVideo = medias[idx];
                medias[idx] = createVideo(src);
                delete oldVideo;
            } else if (medias[idx].currentTime != 0) {
                medias[idx].currentTime = 0;
            }
            if (mediaIsStopped(medias[idx])) { medias[idx].play(); }
        }
        //为了兼容多种浏览器，同时声称多个source节点--20180728var childs = f.childNodes; 
        var childs = medias[idx].childNodes;
        for (var i = childs.length - 1; i >= 0; i--) {
            medias[idx].removeChild(childs[i]);
        }
        var fmts = li.attributes.getNamedItem('sgFmts').nodeValue.split(',');
        for (var i = 0; i < fmts.length; i++) {
            var oSource = document.createElement("source");
            oSource.src = src + '.' + fmts[i];
            oSource.type = 'audio/' + fmts[i];
            medias[idx].appendChild(oSource);
        }

        videoLayer.appendChild(medias[idx]);
        curIdx = idx;
        li.style.backgroundColor = 'lightblue';

        //显示歌词--benjamin20191125
        //debugger;
        if (!isVideo) {
            function showLrc() {

                var ul = $("#lrclist")[0]; //获取ul
                $("#lrclist").empty();
                var i = 0;
                var lrcJSON = lrcJSONCache[li.innerHTML];
                // debugger;
                $.each(lrcJSON, function(key, value) {//遍历lrc
                    // lrcTime[i++] = parseFloat(key.substr(1,3)) * 60 + parseFloat(key.substring(4,10));//00:00.000转化为00.000格式
                    ul.innerHTML += "<li><p>" + ((lrcJSON[key] === null || lrcJSON[key] === undefined || lrcJSON[key] === "") ? "&nbsp;" : lrcJSON[key]) + "</p></li>"; //ul里填充歌词
                });
                //lrcTime[lrcTime.length] = lrcTime[lrcTime.length-1] + 3;//如不另加一个结束时间，到最后歌词滚动不到最后一句


                var currentLine = 0; //当前播放到哪一句歌词了
                var currentTime; //当前播放的时间
                //var audio = document.getElementById("audio");
                //var ppxx;//保存ul的translateY值
                var $li = $("#lrclist>li"); //获取所有li
                //debugger;
                var lrcTime = lrcTimeCache[li.innerHTML];
                var lastJ = -2;
                medias[idx].ontimeupdate = function() {//audio时间改变事件
                    //debugger;
                    currentTime = medias[idx].currentTime;
                    //debugger;
                    for (var j = currentLine, len = lrcTime.length; j < len; j++) {//这样写的话，liclick时需要重置currentLine为0，索性从0开始找吧
                        //for (var j=0, len=lrcTime.length; j<len; j++){
                        if (
                                (currentTime < lrcTime[j + 1]
                                  || j + 1 >= lrcTime.length//最后一行时
                                )
                                && (currentTime >= lrcTime[j]
                                  || j === 0//第一行时(如果没这句,当歌词第一句的时间比较大时,就一直不满足了
                                )
                               ) {
                            currentLine = j;
                            if (//lastJ!==j&&//这样的话，liclick时lastJ没有重置
                                    (!$li.eq(currentLine).hasClass('on')) &&
                                    (!$pf.stringIsNullOrWhiteSpace($li.get(currentLine).innerText))) {
                                // debugger;
                                //ppxx = 250-(currentLine*32);
                                // ul.style.transform = "translateY("+ppxx+"px)";
                                // debugger;
                                // ul.scrollTop=ppxx;
                                //$('.sellgirl_player_lrcContainer').scrollTop(currentLine*32);

                                var ppxx = $li.get(currentLine).getBoundingClientRect().top
                                      - $li.get(0).getBoundingClientRect().top;
                                //$('.sellgirl_player_lrcContainer').animate({scrollTop:currentLine*32},200);
                                $('.sellgirl_player_lrcContainer').animate({ scrollTop: ppxx }, 200);

                                // console.log(ppxx);
                                // ul.scrollTop="1000px";
                                // $li.get(currentLine-1).className="";
                                $li.removeClass('on');
                                // console.log("on"+currentLine);
                                $li.get(currentLine).className = "on";

                                lastJ = j;
                            }
                            break;
                        }
                    }
                };
                medias[idx].onseeked = function() {//audio进度更改后事件
                    currentTime = medias[idx].currentTime;
                    // console.log("  off"+currentLine);
                    $li.get(currentLine).className = "";
                    for (var k = 0, len = lrcTime.length; k < len; k++) {
                        if (
                                (currentTime < lrcTime[k + 1]
                                  || k + 1 >= lrcTime.length//最后一行时
                                )
                                && currentTime >= lrcTime[k]
                               ) {
                            currentLine = k;
                            lastJ = -2;
                            break;
                        }
                    }
                };
            }
            if (lrcJSONCache[li.innerHTML] === undefined) {
                $.post('getLrc_stream.asp?level=' + '<%Response.Write Request.QueryString("level") %>' + '&fileName=' + encodeURIComponent(li.attributes.getNamedItem('src').nodeValue.replace('./mp3/','')), null, function(data) {
                    if (data !== undefined && data !== null && data !== '') {
                        // $("#lrclist").css('transform','translateY(26px)');

                        var lrcArray = data.split('\r\n');
                        var lrcTitle = '';
                        var lrcJSON = {};
                        // debugger;
                        lrcJSON['[00:00.00]'] = '';//顺序对后面$.foreach是有影响的
                        for (var j = 0; j < lrcArray.length; j++) {
                            if (lrcArray[j].indexOf(']') === 9) {
                                var lrcRow = lrcArray[j].split(']');
                                lrcJSON[lrcRow[0] + ']'] = lrcRow[1];
                            } else {
                                lrcTitle += lrcArray[j];
                            }
                        }
                        //if (lrcJSON['[00:00.00]'] === undefined && lrcJSON['[00:00:00]'] === undefined) {
                            lrcJSON['[00:00.00]'] = lrcTitle;
                        //}

                        lrcJSONCache[li.innerHTML] = lrcJSON;

                        var lrcTime = []; //歌词对应的时间数组
                        i = 0;
                        $.each(lrcJSON, function(key, value) {//遍历lrc
                            lrcTime[i++] = parseFloat(key.substr(1, 3)) * 60 + parseFloat(key.substring(4, 10)); //00:00.000转化为00.000格式
                            // ul.innerHTML += "<li><p>"+lrcJSON[key]+"</p></li>";//ul里填充歌词
                        });
                        lrcTimeCache[li.innerHTML] = lrcTime;
                        showLrc();
                        setLrcModel(document.getElementById('nexLrcModeBtn'));

                    } else {
                        delete lrcJSONCache[li.innerHTML];
                        delete lrcTimeCache[li.innerHTML];
                        var ul = $("#lrclist")[0]; //获取ul
                        $("#lrclist").empty();
                        ul.innerHTML = "<li>无歌词</li>";

                    }
                });
            } else {
                showLrc();
            }

        }
    }
    function play(idx) {
        var lis = getPlayLis();
        if (!lis[idx]) { idx = 0 };
        liClick(lis[idx]);
    }
    function playNext() {
        // debugger;       
        switch (playMode) {
            case 0:
                play(curIdx + 1);
                break;
            case 1:
                play(curIdx);
                break;
            case 2: //Random 和传统随机不同,随机抽取,全部轮一遍后再重复
                // if(randomPlayList.length<1){
                //     var lis = getPlayLis();
                //     for (var i = 0; i < lis.length; i++) {
                //         randomPlayList.push(i);
                //     }
                // }
                // play($pf.listRandomTake(randomPlayList,1,true)[0]);

                play(randomPlayContainer.randomTake(1));
                setPlayModelLabel(document.getElementsByClassName('sellgirl_player_list_toolbar')[0].children[0]);
                break;
            default:
                break;
        }
    }
    function setPlayModelLabel(dom) {
        switch (playMode) {
            case 0:
                dom.innerHTML = "&lt;顺序播放&gt;";
                break;
            case 1:
                dom.innerHTML = "&lt;单曲循环&gt;";
                break;
            case 2:
                dom.innerHTML = "&lt;随机播放(rest:" + randomPlayContainer.getRestCount() + ")&gt;";
                break;
            default:
                break;
        }
    }
    function setLrcModel(dom) {
        switch (lrcMode) {
            case 0:
                dom.innerHTML = "&lt;多行歌词&gt;";
                break;
            case 1:
                dom.innerHTML = "&lt;单行歌词&gt;";
                break;
            default:
                break;
        }

        switch (lrcMode) {
            case 0:
                $('.sellgirl_player_lrcContainer').height('auto');
                break;
            case 1:
                var lrcLi = $('.sellgirl_player_lrc li').eq(0);
                if (lrcLi.length > 0) {
                    $('.sellgirl_player_lrcContainer').height(lrcLi.height() + 21); //21是偏差值
                }
                break;
            default:
                break;
        }
    }
    var isSongListClosed = false;
    function expandSongList(useAnimate) {
        var playerListTop = $('.sellgirl_player_list_top');
        function setTopHeight(height) {
            if (useAnimate !== false) {
                playerListTop.animate({ height: height + 'px' }, 200);
            } else {
                playerListTop.height(height + 'px');
            }
        }
        var rect = playerListTop[0].getBoundingClientRect();
        var h = $(window).height() - rect.top - 5; //5为偏差值,否则会多1个滚动条
        playerListTop.height("auto");
        var autoRect = playerListTop[0].getBoundingClientRect();
        // debugger;
        playerListTop.height("0px");
        if (autoRect.height > h) {
            // playerListTop.height(h);
            // playerListTop.animate({height:h+'px'},200);
            setTopHeight(h);
        } else {
            //playerListTop.height(autoRect.height);
            // playerListTop.animate({height:autoRect.height+'px'},200);
            setTopHeight(autoRect.height);
        }
        // $('.sellgirl_player_list_top').animate({height:"100px"},200);
        isSongListClosed = false;
    }
    function closeSongList(useAnimate) {
        if (useAnimate !== false) {
            $('.sellgirl_player_list_top').animate({ height: '0px' }, 200);
        } else {
            $('.sellgirl_player_list_top').height('0px');
        }
        isSongListClosed = true;
    }
    function selectSong(dom) {
        var playerListTop = $('.sellgirl_player_list_top');
        // var rect = dom.getBoundingClientRect();
        // var h = $(window).height() - rect.top - 5;//5为偏差值,否则会多1个滚动条
        // debugger;
        // if(playerListTop.height()>1){
        // if(playerListTop.css('display')!=='none'){
        if (!isSongListClosed) {
            // playerListTop.hide();
            // playerListTop.height("0px");
            closeSongList();
            // playerListTop.height(0);
            // playerListTop.prev().hide();
            dom.innerHTML = "<选歌...>";
        } else {
            // // debugger;
            // //  playerListTop.prev().show();
            //  var rect = playerListTop[0].getBoundingClientRect();
            // var h = $(window).height() - rect.top -5;//5为偏差值,否则会多1个滚动条
            // playerListTop.height(h);
            // playerListTop.show();
            // playerListTop.height("auto");
            expandSongList();
            dom.innerHTML = "<收起列表>";
        }
    }

//    var oldOnLoad = window.onload;
//    window.onload = function() {
//        if (oldOnLoad) { oldOnLoad(); }

//        var lis = getPlayLis();
//        var idxs = [];
//        for (var i = 0; i < lis.length; i++) {
//            idxs.push(i);
//        }
//        randomPlayContainer = $pf.listRandomTakeContainer(idxs);

//        //liClick(lis[curIdx]);
//        playNext(); //默认下一首--benjamin20191130

//        if (lis.length < 5) {
//            $('#selectSongBtn').hide();
//            expandSongList(false);
//        } else {
//            // $('.sellgirl_player_list_top').height(0);
//            // $('.sellgirl_player_list_top').hide();
//            // closeSongList();
//            closeSongList(false);
//        }
//        // liClick(getPlayLis()[curIdx]);
//        setPlayModelLabel(document.getElementsByClassName('sellgirl_player_list_toolbar')[0].children[0]);
//        //setLrcModel(document.getElementById('nexLrcModeBtn'));第一次加载歌词是异步的
//    }
    
    $(document).ready(function() {
//        if (oldOnLoad) { oldOnLoad(); }

        var lis = getPlayLis();
        var idxs = [];
        for (var i = 0; i < lis.length; i++) {
            idxs.push(i);
        }
        randomPlayContainer = $pf.listRandomTakeContainer(idxs);

        //liClick(lis[curIdx]);
        playNext(); //默认下一首--benjamin20191130

        if (lis.length < 5) {
            $('#selectSongBtn').hide();
            expandSongList(false);
        } else {
             closeSongList(false);
        }
        // liClick(getPlayLis()[curIdx]);
        setPlayModelLabel(document.getElementsByClassName('sellgirl_player_list_toolbar')[0].children[0]);
        //setLrcModel(document.getElementById('nexLrcModeBtn'));第一次加载歌词是异步的
    });
    function nextPlayMode(dom) {
        // playMode = playMode > 0 ? 0 : playMode + 1; //2种模式时
        playMode = playMode > 1 ? 0 : playMode + 1; //3种模式时
        sPlayMode(playMode);
        setPlayModelLabel(dom);
    }
    function nextLrcMode(dom) {
        lrcMode = lrcMode > 0 ? 0 : lrcMode + 1; //3种模式时
        sLrcMode(lrcMode);
        setLrcModel(dom);
    }

</script>


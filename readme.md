## web.config
在高版本IIS中可能不需要下面的mime配置(写了反而会冲突,因为默认就有了)
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <directoryBrowse enabled="true" />
        <staticContent>
            <!-- <mimeMap fileExtension=".aac" mimeType="audio/aac" /> -->
            <mimeMap fileExtension=".lrc" mimeType="text/plain" />
            <!-- <mimeMap fileExtension=".mp4" mimeType="video/mp4" /> -->
        </staticContent>
    </system.webServer>
</configuration>
